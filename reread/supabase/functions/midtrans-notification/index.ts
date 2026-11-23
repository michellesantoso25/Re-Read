import { createClient } from 'npm:@supabase/supabase-js@2';

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { 'Content-Type': 'application/json' },
});

async function sha512Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(value));
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

function serviceKey(): string | undefined {
  const legacy = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (legacy) return legacy;
  try {
    const keys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') ?? '{}') as Record<string, string>;
    return keys.default ?? Object.values(keys)[0];
  } catch {
    return undefined;
  }
}

Deno.serve(async (request) => {
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  try {
    const body = await request.json();
    const orderId = String(body.order_id ?? '');
    const statusCode = String(body.status_code ?? '');
    const grossAmount = String(body.gross_amount ?? '');
    const signature = String(body.signature_key ?? '').toLowerCase();
    const signatureSecret = Deno.env.get('MIDTRANS_SIGNATURE_SECRET_KEY')?.trim();
    if (!signatureSecret) return json({ error: 'Webhook signature secret is missing.' }, 500);
    if (signature !== await sha512Hex(`${orderId}${statusCode}${grossAmount}${signatureSecret}`)) {
      return json({ error: 'Invalid Midtrans signature.' }, 401);
    }

    const amount = Number(grossAmount);
    if (!Number.isSafeInteger(amount)) return json({ error: 'Invalid payment amount.' }, 400);
    const transactionStatus = String(body.transaction_status ?? '').toLowerCase();
    const fraudStatus = String(body.fraud_status ?? '').toLowerCase();
    const paid = ['settlement', 'capture'].includes(transactionStatus)
      && statusCode === '200'
      && (transactionStatus !== 'capture' || fraudStatus === 'accept');

    const url = Deno.env.get('SUPABASE_URL');
    const key = serviceKey();
    if (!url || !key) return json({ error: 'Supabase function configuration is missing.' }, 500);
    const admin = createClient(url, key, { auth: { persistSession: false } });
    const { error } = await admin.rpc('record_midtrans_notification', {
      p_midtrans_order_id: orderId,
      p_gross_amount: amount,
      p_transaction_status: transactionStatus,
      p_paid: paid,
    });
    if (error) throw error;
    return json({ received: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error('Could not process Midtrans notification:', message, error);
    return json({ error: message }, 500);
  }
});
