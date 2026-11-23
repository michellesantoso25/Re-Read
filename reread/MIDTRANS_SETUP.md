# Midtrans Snap setup

The Flutter app's root `.env` is bundled with the client. Keep only the
Supabase URL and anon key there; never put Midtrans secrets in it.

## Production keys

Fill `supabase/functions/.env` locally:

```dotenv
MIDTRANS_ENV=production
MIDTRANS_SERVER_KEY=YOUR_PRODUCTION_SERVER_KEY
MIDTRANS_SIGNATURE_SECRET_KEY=YOUR_PRODUCTION_SIGNATURE_SECRET_KEY
# Optional; set this after the marketplace web URL is deployed.
# APP_BASE_URL=https://YOUR_MARKETPLACE_DOMAIN
```

The Server Key must have **Write** permission for **Snap Checkout**. Keep both
keys on the backend and out of Git. Production payments can charge real money.

## Apply the database migration and deploy

From the Flutter project directory:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase migration list --remote
supabase migration fetch --remote
supabase db push --remote
supabase secrets set --env-file supabase/functions/.env
supabase functions deploy create-midtrans-transaction
supabase functions deploy midtrans-notification
```

Supabase injects its own project URL and API keys into deployed Edge Functions.
The checkout function validates book prices and seller IDs from `books`, then
creates the Snap transaction with a per-order finish callback to
`/#/payment-status/<order_id>` when optional `APP_BASE_URL` is configured. Until
the web app is deployed, leave that secret unset; the originating Re:Read tab
shows and polls payment status while Snap is open separately. The notification
function verifies Midtrans'
Signature Secret Key and amount, then updates the authoritative order status.
Each new Snap request also overrides its notification destination to this
project's `midtrans-notification` Edge Function, so new payment webhooks do not
depend on the Dashboard URL being configured. Keep the Dashboard URL configured
as a fallback, separately for Sandbox and Production.
The payment status page reads the order as its buyer and polls while Midtrans
reports `pending`; it never trusts redirect query parameters as proof of payment.

Set the Midtrans Production Payment Notification URL to:

```text
https://YOUR_PROJECT_REF.supabase.co/functions/v1/midtrans-notification
```

When payment settles, `seller_wallet_ledger` receives each seller's original
book subtotal once. Migration `202611230001` backfills missing ledger rows for
orders already marked paid and makes later settlement notifications repair a
missing row idempotently. Apply the latest migrations through `202611230001` before
deploying the functions so the payment status lifecycle and buyer RLS policies
are present. The seller dashboard shows this internal earnings balance;
bank withdrawals are not included. The voucher field remains visible in
checkout, but no voucher codes are active and no discount is applied.
