import 'package:reread/main.dart';

/// Menyimpan daftar buku di memori supaya pindah halaman/genre tidak
/// perlu fetch ulang ke Supabase (tidak ada loading yang terlihat).
class BookRepository {
  static List<Map<String, dynamic>>? _cache;
  static Future<List<Map<String, dynamic>>>? _inflight;

  /// Data yang sudah ada di memori (null kalau belum pernah di-fetch).
  static List<Map<String, dynamic>>? get cached => _cache;

  /// Ambil semua buku yang sudah lolos QC, terbaru dulu.
  /// Pakai [refresh] = true untuk memaksa fetch ulang dari database.
  static Future<List<Map<String, dynamic>>> getBooks({bool refresh = false}) {
    if (!refresh) {
      if (_cache != null) return Future.value(_cache!);
      if (_inflight != null) return _inflight!;
    }

    final request = supabase
        .from('books')
        .select()
        .eq('qc_status', 'approved')
        .order('created_at', ascending: false)
        .then((data) {
      _cache = List<Map<String, dynamic>>.from(data);
      return _cache!;
    }).whenComplete(() => _inflight = null);

    _inflight = request;
    return request;
  }

  /// Buku pada satu genre, diambil dari data di memori.
  static List<Map<String, dynamic>> byGenre(
    List<Map<String, dynamic>> books,
    String genre,
  ) {
    return books.where((b) => b['genre'] == genre).toList();
  }
}