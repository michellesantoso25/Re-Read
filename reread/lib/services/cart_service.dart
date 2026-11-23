import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory cart shared by product details, the navigation bar, and CartPage.
class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();
  static const _storageKey = 'reread_cart_v1';

  final List<Map<String, dynamic>> _items = [];
  SharedPreferences? _preferences;
  Future<void> _pendingWrites = Future<void>.value();

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  int get subtotal =>
      _items.fold<int>(0, (sum, book) => sum + _priceOf(book['price']));

  int get itemCount => _items.length;

  /// Restore the cart before the app is shown so a refresh keeps its contents.
  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _preferences = preferences;
      final stored = preferences.getString(_storageKey);
      if (stored == null || stored.isEmpty) return;

      final decoded = jsonDecode(stored);
      if (decoded is List) {
        _items
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );
        notifyListeners();
      }
    } catch (_) {
      // Keep the app usable if stored cart data is unreadable.
      _items.clear();
    }
  }

  bool add(Map<String, dynamic> book) {
    final key = _key(book);
    if (_items.any((item) => _key(item) == key)) return false;
    _items.add(Map<String, dynamic>.from(book));
    notifyListeners();
    _persist();
    return true;
  }

  /// Replace cached cart rows with canonical listing rows from the database.
  void replaceAll(List<Map<String, dynamic>> books) {
    _items
      ..clear()
      ..addAll(books.map((book) => Map<String, dynamic>.from(book)));
    notifyListeners();
    _persist();
  }

  void removeByIds(Set<String> ids) {
    if (ids.isEmpty) return;
    final countBefore = _items.length;
    _items.removeWhere((item) => ids.contains(item['id']?.toString()));
    if (_items.length != countBefore) {
      notifyListeners();
      _persist();
    }
  }

  void remove(Map<String, dynamic> book) {
    final countBefore = _items.length;
    _items.removeWhere((item) => _key(item) == _key(book));
    if (_items.length != countBefore) {
      notifyListeners();
      _persist();
    }
  }

  void _persist() {
    final preferences = _preferences;
    if (preferences == null) return;
    final snapshot = jsonEncode(_items);
    _pendingWrites = _pendingWrites
        .then((_) => preferences.setString(_storageKey, snapshot))
        .then((_) {})
        .catchError((_) {});
  }

  static int _priceOf(dynamic value) {
    if (value is num) return value.round();
    return num.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  static String _key(Map<String, dynamic> book) {
    final id = book['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '${book['title'] ?? ''}|${book['author'] ?? ''}';
  }
}
