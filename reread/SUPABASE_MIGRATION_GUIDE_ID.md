# Panduan migrasi Supabase CLI Re:Read

Ikuti alur ini di project **staging terlebih dahulu**. Jangan jalankan `db reset` untuk project remote; perintah itu ditujukan untuk database lokal dan dapat menghapus data lokal.

## 1. Siapkan Supabase CLI

Dari root repo (`reread/`), cek CLI terpasang:

```sh
supabase --version
```

Jika belum terpasang, ikuti petunjuk instalasi resmi Supabase CLI. Login dan hubungkan repo ke project staging:

```sh
supabase login
supabase link --project-ref <PROJECT_REF_STAGING>
```

Ambil project ref dari Supabase Dashboard → **Project Settings → General**. Jangan menaruh password database atau secret di source code/git. Saat CLI meminta password database, masukkan melalui prompt.

## 2. Periksa riwayat sebelum push

```sh
supabase migration list --remote
```

Folder migration repo ini berisi versi `202611210001` sampai `202611230001`. Versi `001`–`006` dipulihkan dari salinan lama repo karena sudah tercatat applied pada project ReRead.

Pastikan kolom local/remote masuk akal sebelum melanjutkan:

- Untuk project ReRead yang terlihat pada output CLI, remote `001`–`006` harus sejajar dengan file lokal; dry-run seharusnya merencanakan migration lokal yang belum diterapkan (yang terbaru `202611230001`).
- Setelah push berhasil, jalankan migration list lagi. Semua versi lokal dan remote sampai `202611230001` harus sejajar.
- **Berhenti dan jangan push** jika remote memiliki versi yang tidak ada di folder lokal, ada gap/urutan berbeda, project ref tidak yakin, atau tabel dasar belum ada. Sinkronkan file/riwayat migrasi dengan kondisi project terlebih dahulu. Jangan memakai `migration repair` atau mengubah tabel `supabase_migrations` secara manual tanpa mengaudit schema remote.

Untuk memastikan tabel dasar ada, gunakan perintah read-only ini:

```sh
supabase db query "select to_regclass('public.books') as books, to_regclass('public.orders') as orders;" --read-only --remote
```

Keduanya harus bukan `NULL`. Jika versi CLI yang digunakan tidak menyediakan `db query`, jalankan query yang sama melalui SQL Editor Dashboard; jangan membuat tabel dasar baru secara tebakan.

## 3. Backup staging/production

Pastikan backup database tersedia sebelum migrasi, terutama sebelum production. Migrasi ini menambah kolom, tabel, policy, trigger, dan fungsi; backup adalah jalur pemulihan jika schema project berbeda dari asumsi repo.

## 4. Tinjau rencana perubahan

Jalankan dry-run:

```sh
supabase db push --dry-run --remote
```

Perintah ini hanya menampilkan migration yang akan diterapkan. Pastikan project yang ditautkan adalah staging dan daftar migration sesuai hasil pemeriksaan langkah 2. Jika rencana tidak sesuai, berhenti dan jangan lanjut.

## 5. Terapkan migration ke staging

```sh
supabase db push --remote
```

Jangan tutup terminal sampai perintah selesai. Jika salah satu migration gagal, catat pesan error, **jangan langsung mencoba memperbaiki schema remote manual**, lalu sesuaikan migration berdasarkan schema aktual dan ulangi pemeriksaan riwayat serta dry-run.

## 6. Verifikasi migration staging

```sh
supabase migration list --remote
supabase db query "select to_regclass('public.order_items') as order_items, to_regclass('public.seller_wallet_ledger') as seller_wallet_ledger, to_regclass('public.order_shipments') as order_shipments;" --read-only --remote
```

Ketiga tabel harus ada dan versi `001`–`015` tercatat applied. Pastikan juga kolom `orders.stock_reserved` tersedia:

```sh
supabase db query "select column_name from information_schema.columns where table_schema='public' and table_name='orders' and column_name='stock_reserved';" --read-only --remote
```

## 7. Uji checkout staging sebelum production

1. Jika origin web staging sudah tersedia, isi `APP_BASE_URL`; jika belum, biarkan tidak diset. Lalu deploy versi Edge Functions terbaru (termasuk `create-midtrans-transaction` dan `midtrans-notification`) ke staging dan isi secret **sandbox** di Supabase Dashboard → Edge Functions → Secrets.
2. Pakai akun seller untuk membuat listing beserta foto. Statusnya harus `pending_review` dan listing belum boleh muncul ke buyer.
3. Moderator tepercaya dapat meninjau staging listing melalui SQL Editor Dashboard:

```sql
select id, seller_id, title, author, price, cover, condition, condition_checklist
from public.books
where qc_status = 'pending_review'
order by id;
```

Setujui atau tolak listing yang sudah diperiksa dengan ID yang benar:

```sql
update public.books set qc_status = 'approved' where id = '<ID_LISTING>';
-- Atau, untuk menolak:
-- update public.books set qc_status = 'rejected' where id = '<ID_LISTING>';
```

Jalankan review sebagai operator tepercaya di Dashboard, bukan dari aplikasi seller. Jangan pernah memasukkan service-role key ke web app.

4. Dari akun buyer berbeda, checkout listing approved dan selesaikan pembayaran Midtrans sandbox. Pastikan stok turun satu kali dan ledger seller tercatat satu kali.
5. Buat checkout sandbox lain lalu biarkan expired/cancel. Pastikan stok kembali satu kali.
6. Dari transaksi seller, masukkan kurir dan nomor resi. Pastikan buyer dapat melihatnya di riwayat transaksi.
7. Cek Edge Function logs untuk callback sukses, pending, expire, cancel, dan webhook berulang.

## 8. Migrasikan production

Setelah staging lolos:

1. Buat/konfirmasi backup production.
2. Tautkan CLI ke project production: `supabase link --project-ref <PROJECT_REF_PRODUCTION>`.
3. Jalankan `supabase migration list --remote` dan pastikan sejarahnya sesuai dengan file lokal. Berhenti jika ada versi yang berbeda atau belum direkonsiliasi.
4. Jalankan `supabase db push --dry-run --remote`, tinjau project ref dan migration yang akan diterapkan.
5. Jika rencananya benar, jalankan `supabase db push --remote`.
6. Verifikasi versi dengan `supabase migration list --remote` dan query di langkah 6.
7. Jika origin web production sudah tersedia, set `APP_BASE_URL` tanpa trailing slash. Jika belum, biarkan kosong dan deploy Edge Functions versi production (`supabase functions deploy create-midtrans-transaction --project-ref <PROJECT_REF_PRODUCTION>` dan `supabase functions deploy midtrans-notification --project-ref <PROJECT_REF_PRODUCTION>`) dengan **production** secrets. Set URL Midtrans Payment Notification ke Edge Function `midtrans-notification`.

Jangan memakai secret sandbox di production atau sebaliknya. Panduan Supabase CLI resmi: [Deploy database migrations](https://supabase.com/docs/guides/deployment/database-migrations) dan [Supabase CLI reference](https://supabase.com/docs/reference/cli/supabase-db-push).
