import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const shippingFees: Record<string, number> = {
  regular: 18000,
  express: 30000,
  economy: 12000,
  seller: 0,
};
const paymentMethods: Record<string, string[]> = {
  QRIS: ['gopay', 'shopeepay'],
  'E-Wallet': ['gopay', 'ovo', 'dana', 'shopeepay'],
  'Credit/Debit Card': ['credit_card'],
  'Virtual Account': ['bank_transfer'],
};

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});

function readSupabaseKey(legacyName: string, modernName: string): string | undefined {
  const legacy = Deno.env.get(legacyName);
  if (legacy) return legacy;
  try {
    const keys = JSON.parse(Deno.env.get(modernName) ?? '{}') as Record<string, string>;
    return keys.default ?? Object.values(keys)[0];
  } catch {
    return undefined;
  }
}

function describeError(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (error && typeof error === 'object') {
    const value = error as Record<string, unknown>;
    const parts = [value.message, value.details, value.hint, value.code]
      .filter((part) => typeof part === 'string' && part.length > 0)
      .map(String);
    if (parts.length) return parts.join(' · ');
  }
  return String(error);
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  try {
    const authorization = request.headers.get('Authorization');
    if (!authorization) return json({ error: 'Sign in before checkout.' }, 401);

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const anonKey = readSupabaseKey('SUPABASE_ANON_KEY', 'SUPABASE_PUBLISHABLE_KEYS');
    const serviceKey = readSupabaseKey('SUPABASE_SERVICE_ROLE_KEY', 'SUPABASE_SECRET_KEYS');
    const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')?.trim();
    const appBaseUrl = Deno.env.get('APP_BASE_URL')?.trim().replace(/\/+$/, '');
    const environment = (Deno.env.get('MIDTRANS_ENV') ?? 'sandbox').trim().toLowerCase();
    if (!supabaseUrl || !anonKey || !serviceKey || !serverKey) {
      return json({ error: 'Payment backend is missing required secrets.' }, 500);
    }
    let finishUrl: string | undefined;
    if (appBaseUrl) {
      let parsedAppBaseUrl: URL;
      try {
        parsedAppBaseUrl = new URL(appBaseUrl);
      } catch {
        return json({ error: 'APP_BASE_URL must be a valid HTTPS app origin.' }, 500);
      }
      if (parsedAppBaseUrl.protocol !== 'https:' && parsedAppBaseUrl.hostname !== 'localhost') {
        return json({ error: 'APP_BASE_URL must use HTTPS outside localhost.' }, 500);
      }
    }
    if (!['sandbox', 'production'].includes(environment)) {
      return json({ error: 'MIDTRANS_ENV must be sandbox or production.' }, 500);
    }

    const authClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false },
    });
    const { data: authData, error: authError } = await authClient.auth.getUser();
    if (authError || !authData.user) return json({ error: 'Your session expired. Sign in again.' }, 401);

    const input = await request.json();
    const bookIds = Array.isArray(input.book_ids)
      ? [...new Set(input.book_ids.map(String))]
      : [];
    if (bookIds.length === 0 || bookIds.length > 30) {
      return json({ error: 'Your cart is empty or too large.' }, 400);
    }

    const shippingBySeller = input.shipping_by_seller;
    const selectedPayment = String(input.payment_method ?? '');
    const enabledPayments = paymentMethods[selectedPayment];
    if (!enabledPayments) return json({ error: 'Choose a valid payment method.' }, 400);

    const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });
    const { data: books, error: booksError } = await admin
      .from('books')
      .select('id,title,price,stock,qc_status,seller_id')
      .in('id', bookIds);
    if (booksError) throw booksError;
    if (!books || books.length !== bookIds.length) {
      return json({ error: 'Some books are no longer available.' }, 409);
    }

    let subtotal = 0;
    const sellerIds = new Set<string>();
    for (const book of books) {
      const price = Number(book.price);
      if (book.qc_status !== 'approved' || Number(book.stock) < 1) {
        return json({ error: `${book.title} is no longer available.` }, 409);
      }
      if (!book.seller_id) {
        return json({ error: `Seller ownership is missing for “${book.title}”.` }, 409);
      }
      if (!Number.isSafeInteger(price) || price < 1) {
        return json({ error: `Invalid price for “${book.title}”.` }, 409);
      }
      subtotal += price;
      sellerIds.add(String(book.seller_id));
    }

    const address = input.delivery_address;
    if (!address || !['name', 'phone', 'street', 'city', 'postal_code']
      .every((field) => String(address[field] ?? '').trim())) {
      return json({ error: 'Complete the delivery address before checkout.' }, 400);
    }
    if (!shippingBySeller || typeof shippingBySeller !== 'object') {
      return json({ error: 'Choose shipping for every seller.' }, 400);
    }
    const selectedSellerIds = Object.keys(shippingBySeller).sort();
    const expectedSellerIds = [...sellerIds].sort();
    if (JSON.stringify(selectedSellerIds) !== JSON.stringify(expectedSellerIds)) {
      return json({ error: 'Shipping selections do not match the sellers in your cart.' }, 400);
    }

    let shippingTotal = 0;
    for (const sellerId of expectedSellerIds) {
      const method = String(shippingBySeller[sellerId]?.method ?? '');
      const fee = shippingFees[method];
      if (fee === undefined) return json({ error: 'Invalid shipping option.' }, 400);
      shippingTotal += fee;
    }

    const grossAmount = subtotal + shippingTotal;
    if (input.expected_gross_amount !== undefined) {
      const expectedGrossAmount = Number(input.expected_gross_amount);
      if (!Number.isSafeInteger(expectedGrossAmount) || expectedGrossAmount < 1) {
        return json({ error: 'Invalid checkout total.' }, 400);
      }
      if (expectedGrossAmount !== grossAmount) {
        return json({
          code: 'price_changed',
          error: 'The listing price changed before checkout.',
          quote: {
            subtotal,
            shipping_total: shippingTotal,
            gross_amount: grossAmount,
            books: books.map((book) => ({
              id: book.id,
              title: book.title,
              price: book.price,
              stock: book.stock,
              qc_status: book.qc_status,
              seller_id: book.seller_id,
            })),
          },
        }, 409);
      }
    }

    const orderId = `reread_${crypto.randomUUID()}`;
    if (appBaseUrl) {
      finishUrl = `${appBaseUrl}/#/payment-status/${encodeURIComponent(orderId)}`;
    }
    const { data: order, error: orderError } = await admin.from('orders').insert({
      buyer_id: authData.user.id,
      midtrans_order_id: orderId,
      subtotal,
      shipping_total: shippingTotal,
      discount: 0,
      platform_subsidy: 0,
      gross_amount: grossAmount,
      voucher_code: null,
      delivery_address: address,
    }).select('id').single();
    if (orderError) throw orderError;

    const orderItems = books.map((book) => ({
      order_id: order.id,
      book_id: String(book.id),
      seller_id: book.seller_id,
      title: String(book.title),
      unit_price: Number(book.price),
    }));
    const { error: itemsError } = await admin.from('order_items').insert(orderItems);
    if (itemsError) throw itemsError;

    const { error: reservationError } = await admin.rpc('reserve_order_stock', {
      p_order_id: order.id,
    });
    if (reservationError) {
      await admin.from('orders')
        .update({ status: 'failed', payment_status: 'failed' })
        .eq('id', order.id);
      return json({ error: 'A book in your cart was just sold or is no longer available. Refresh your cart.' }, 409);
    }

    const apiUrl = environment === 'production'
      ? 'https://app.midtrans.com/snap/v1/transactions'
      : 'https://app.sandbox.midtrans.com/snap/v1/transactions';
    const notificationUrl = `${supabaseUrl.replace(/\/+$/, '')}/functions/v1/midtrans-notification`;
    const snapPayload: Record<string, unknown> = {
      transaction_details: { order_id: orderId, gross_amount: grossAmount },
      enabled_payments: enabledPayments,
      customer_details: {
        email: authData.user.email ?? undefined,
        first_name: String(authData.user.user_metadata?.full_name ?? 'Re:Read Customer').slice(0, 50),
      },
    };
    if (finishUrl) {
      snapPayload.callbacks = { finish: finishUrl, error: finishUrl };
    }
    if (finishUrl && enabledPayments.includes('gopay')) {
      snapPayload.gopay = { enable_callback: true, callback_url: finishUrl };
    }
    let midtransResponse: Response;
    try {
      midtransResponse = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          Authorization: `Basic ${btoa(`${serverKey}:`)}`,
          'Content-Type': 'application/json',
          // Send webhook notifications here even when the merchant dashboard URL is unset.
          'X-Override-Notification': notificationUrl,
        },
        body: JSON.stringify(snapPayload),
      });
    } catch (error) {
      await admin.rpc('release_order_stock', { p_order_id: order.id });
      await admin.from('orders')
        .update({ status: 'failed', payment_status: 'failed' })
        .eq('id', order.id);
      throw error;
    }
    const responseText = await midtransResponse.text();
    let midtransBody: Record<string, unknown> = {};
    try {
      midtransBody = JSON.parse(responseText);
    } catch {
      // Return a safe response excerpt below for diagnostics.
    }
    const token = String(midtransBody.token ?? '');
    const base = environment === 'production'
      ? 'https://app.midtrans.com'
      : 'https://app.sandbox.midtrans.com';
    const redirectUrl = String(midtransBody.redirect_url ?? '')
      || (token ? `${base}/snap/v3/redirection/${encodeURIComponent(token)}` : '');
    if (!midtransResponse.ok || !token || !redirectUrl) {
      await admin.rpc('release_order_stock', { p_order_id: order.id });
      await admin.from('orders').update({ status: 'failed', payment_status: 'failed' }).eq('id', order.id);
      const message = Array.isArray(midtransBody.error_messages)
        ? midtransBody.error_messages.map(String).join(' · ')
        : String(midtransBody.status_message ?? midtransBody.message ?? '').trim()
          || (responseText.trim()
            ? `Unexpected Midtrans response (HTTP ${midtransResponse.status}): ${responseText.trim().slice(0, 400)}`
            : `Midtrans returned an empty response (HTTP ${midtransResponse.status}).`);
      console.error('Midtrans Snap API error', midtransResponse.status, message);
      return json({ error: message, midtrans_status: midtransResponse.status }, 502);
    }

    const { error: updateError } = await admin.from('orders').update({
      snap_token: token,
      redirect_url: redirectUrl,
    }).eq('id', order.id);
    if (updateError) {
      await admin.rpc('release_order_stock', { p_order_id: order.id });
      await admin.from('orders')
        .update({ status: 'failed', payment_status: 'failed' })
        .eq('id', order.id);
      throw updateError;
    }
    return json({
      order_id: orderId,
      redirect_url: redirectUrl,
      subtotal,
      shipping_total: shippingTotal,
      gross_amount: grossAmount,
    });
  } catch (error) {
    const message = describeError(error);
    console.error('Could not start Midtrans checkout:', message, error);
    return json({ error: message || 'Could not start checkout.' }, 500);
  }
});
