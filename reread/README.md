# Re:Read

Flutter web marketplace for pre-loved books. Buyers can browse approved listings, save books to a local cart, create orders, and pay through Midtrans. Sellers can submit book listings and view their catalog and recorded earnings.

## Run locally

1. Install the Flutter SDK version required by `pubspec.yaml` (`Dart >= 3.12.1`).
2. Copy `.env.example` to `.env` and set `SUPABASE_URL` and the public `SUPABASE_PUBLISHABLE_KEY` (or legacy `SUPABASE_ANON_KEY`) for the Supabase project. These are compiled into the client bundle; never put a service-role key or Midtrans server/signature key here.
3. Run `flutter pub get`, then `flutter run -d chrome`.

## Production deployment checklist

- Apply all SQL migrations through `202611230001` in `supabase/migrations` to the production Supabase project using the Supabase CLI guide. Confirm row-level security policies on `books`, `profiles`, `users`, and storage buckets match the app's read/write flows. The checkout migration covers buyer order access and seller ledger access; the seller-order migration grants sellers access only to their own order records. The latest migration backfills wallet ledger entries for paid orders.
- Deploy both Edge Functions in `supabase/functions` and set production secrets in Supabase's function secret store: `MIDTRANS_ENV=production`, `MIDTRANS_SERVER_KEY`, `MIDTRANS_SIGNATURE_SECRET_KEY`, `APP_BASE_URL` (optional custom return origin; omit until web hosting is ready), `SUPABASE_URL`, and the server-only Supabase secret/service-role key. Do not deploy the local ignored `supabase/functions/.env` file.
- Set the Midtrans payment notification URL to the deployed `midtrans-notification` function. When `APP_BASE_URL` is set, the finish callback returns buyers to the order-specific payment status page. Without it, the Re:Read tab keeps polling status while Snap is open in a separate tab; settlement is confirmed by the signed webhook. Confirm the production Snap domain, allowed payment methods, and notification signature with a real production account.
- Configure Supabase Auth email confirmation, SMTP, site URL, and redirect allowlist for the final domain. Verify account creation and password recovery end to end.
- Publish and verify the final Terms, Privacy, Returns/Refunds, shipping, seller payout, and customer support details before opening real transactions. Terms and Privacy pages are not yet implemented; the footer currently links returns information to FAQs.
- Seller shipment confirmation and buyer-visible tracking numbers are implemented. Cancellation/refund handling, a full order detail page, and a moderation panel are still missing; moderation currently requires a trusted operator.
- Validate listing photo storage policies, moderation/QC workflow, seller payout lifecycle, and production RLS using separate buyer and seller accounts.
- Build and smoke test the deployed web app on mobile and desktop, including payment success, pending, cancellation, expiry, and webhook retries.

The code repository cannot confirm production Supabase, Midtrans, DNS, SMTP, legal, or support configuration. Treat deployment as not production-ready until each external checklist item is verified.
