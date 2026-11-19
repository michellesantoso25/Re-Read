import 'package:flutter/foundation.dart';

/// In-memory cart shared by product details, the navigation bar, and CartPage.
class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  int get subtotal =>
      _items.fold<int>(0, (sum, book) => sum + _priceOf(book['price']));

  int get itemCount => _items.length;

  bool add(Map<String, dynamic> book) {
    final key = _key(book);
    if (_items.any((item) => _key(item) == key)) return false;
    _items.add(Map<String, dynamic>.from(book));
    notifyListeners();
    return true;
  }

  void remove(Map<String, dynamic> book) {
    _items.removeWhere((item) => _key(item) == _key(book));
    notifyListeners();
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
