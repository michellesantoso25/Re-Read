import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../component/top_bar.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final Color bgColor = const Color(0xFFF0E5DD);
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;
  List _orders = [];
  Map? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please log in as a seller to view transactions.';
          _isLoading = false;
        });
        return;
      }

      // Ambil daftar order milik seller yang sedang login
      final ordersResponse = await _supabase
          .from('orders')
          .select()
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);

      final rawOrders = List.from(ordersResponse);

      // Ambil judul buku dari tabel books berdasarkan book_id
      final bookIds = rawOrders
          .map((o) => o['book_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      final bookTitles = {};
      if (bookIds.isNotEmpty) {
        final booksResponse = await _supabase
            .from('books')
            .select('id, title')
            .inFilter('id', bookIds);

        for (final book in booksResponse) {
          bookTitles[book['id']] = book['title']?.toString() ?? 'Untitled Book';
        }
      }

      final enrichedOrders = [];
      for (final order in rawOrders) {
        final item = Map.from(order as Map);
        item['book_title'] =
            bookTitles[item['book_id']] ?? 'Book #${item['book_id']}';
        enrichedOrders.add(item);
      }

      if (!mounted) return;
      setState(() {
        _orders = enrichedOrders;
        if (_orders.isNotEmpty) {
          final currentId = _selectedOrder?['id'];
          Map? found;
          for (final o in _orders) {
            if (o['id'] == currentId) {
              found = o as Map;
              break;
            }
          }
          _selectedOrder = found ?? (_orders.first as Map);
        } else {
          _selectedOrder = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(dynamic orderId, String nextStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': nextStatus})
          .eq('id', orderId);

      await _fetchOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1CB454),
          content: Text('Order status updated to ${_formatStatusLabel(nextStatus)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE52E2E),
          content: Text('Failed to update status: $e'),
        ),
      );
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'to_ship':
        return 'To Ship';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationOrders = _orders.where((o) {
      final s = (o['status'] ?? '').toString().toLowerCase();
      return s == 'pending' || s == 'rejected';
    }).toList();

    final toShipOrders = _orders.where((o) {
      final s = (o['status'] ?? '').toString().toLowerCase();
      return s == 'approved' || s == 'to_ship';
    }).toList();

    final outForDeliveryOrders = _orders.where((o) {
      final s = (o['status'] ?? '').toString().toLowerCase();
      return s == 'out_for_delivery';
    }).toList();

    final deliveredOrders = _orders.where((o) {
      final s = (o['status'] ?? '').toString().toLowerCase();
      return s == 'delivered';
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Transaction History'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction history',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track purchases and get help when needed.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _fetchOrders,
                  icon: const Icon(Icons.refresh, color: Color(0xFFFF5500)),
                  tooltip: 'Refresh orders',
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: Color(0xFFFF5500)),
                ),
              )
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFE52E2E)),
                ),
              )
            else ...[
              // ROW 1: 3 Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCard(
                      title: 'Transaction verification',
                      centerTitle: true,
                      children: verificationOrders.isEmpty
                          ? [_buildEmptyNote('No pending verification')]
                          : verificationOrders.map((order) {
                              final status = (order['status'] ?? 'pending').toString().toLowerCase();
                              final isRejected = status == 'rejected';
                              return _buildListItem(
                                order: order,
                                bookName: order['book_title'],
                                badgeText: isRejected ? 'Rejected' : 'Approve',
                                badgeColor: isRejected
                                    ? const Color(0xFFE52E2E)
                                    : const Color(0xFF1CB454),
                                onBadgeTap: isRejected
                                    ? null
                                    : () => _updateOrderStatus(order['id'], 'to_ship'),
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildCard(
                      title: 'To Shipped',
                      centerTitle: true,
                      children: toShipOrders.isEmpty
                          ? [_buildEmptyNote('No orders to ship')]
                          : toShipOrders.map((order) {
                              return _buildListItem(
                                order: order,
                                bookName: order['book_title'],
                                badgeText: 'Ship',
                                badgeColor: const Color(0xFFFF5500),
                                onBadgeTap: () =>
                                    _updateOrderStatus(order['id'], 'out_for_delivery'),
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildCard(
                      title: 'Out for Delivery',
                      centerTitle: true,
                      children: outForDeliveryOrders.isEmpty
                          ? [_buildEmptyNote('No orders in transit')]
                          : outForDeliveryOrders.map((order) {
                              return _buildListItem(
                                order: order,
                                bookName: order['book_title'],
                                badgeText: 'Check',
                                badgeColor: const Color(0xFFFF5500),
                                onBadgeTap: () =>
                                    _updateOrderStatus(order['id'], 'delivered'),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ROW 2: 2 Cards (1/3 width and 2/3 width)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildCard(
                      title: 'Delivered',
                      centerTitle: true,
                      children: deliveredOrders.isEmpty
                          ? [_buildEmptyNote('No delivered orders yet')]
                          : deliveredOrders.map((order) {
                              return _buildListItem(
                                order: order,
                                bookName: order['book_title'],
                                badgeText: 'Done',
                                badgeColor: const Color(0xFF27784A),
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildSellerTransactionCard(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    bool centerTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          _buildGlowTitle(title),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSellerTransactionCard() {
    final selected = _selectedOrder;
    final status = (selected?['status'] ?? '').toString().toLowerCase();

    String verificationText = 'Book Verification: Pending';
    Color verificationColor = const Color(0xFF888888);

    if (status == 'rejected') {
      verificationText = 'Book Verification: Rejected';
      verificationColor = const Color(0xFFE52E2E);
    } else if (status == 'approved' ||
        status == 'to_ship' ||
        status == 'out_for_delivery' ||
        status == 'delivered') {
      verificationText = 'Book Verification: Approved';
      verificationColor = const Color(0xFF1CB454);
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlowTitle('Seller Transaction'),
          const SizedBox(height: 24),
          Text(
            selected == null
                ? 'No active seller transactions'
                : 'Order #RR-${selected['id']} · Seller tab visibly available',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)),
          ),
          const SizedBox(height: 24),
          Text(
            selected == null
                ? 'Waiting for incoming buyer orders.'
                : '${selected['book_title']} · ${_formatStatusLabel(status)}',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 24),
          Text(
            selected == null ? 'Book Verification: -' : verificationText,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected == null ? const Color(0xFF888888) : verificationColor,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5500),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: selected == null
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Issue reported for Order #RR-${selected['id']}'),
                      ),
                    );
                  },
            child: Text(
              'Report Issue',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFFF5500),
        shadows: [
          Shadow(
            color: const Color(0xFFFF5500).withOpacity(0.4),
            blurRadius: 16.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF999999)),
      ),
    );
  }

  Widget _buildListItem({
    required Map order,
    required String bookName,
    required String badgeText,
    required Color badgeColor,
    VoidCallback? onBadgeTap,
  }) {
    final isSelected = _selectedOrder?['id'] == order['id'];

    return InkWell(
      onTap: () => setState(() => _selectedOrder = order),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAEDE8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5500) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                bookName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF333333)),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onBadgeTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}