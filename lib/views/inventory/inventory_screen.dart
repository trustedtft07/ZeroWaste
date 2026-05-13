import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'add_food_screen.dart';
import 'food_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  final String userId;
  const InventoryScreen({super.key, required this.userId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _firestoreService = FirestoreService();
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua', 'Hampir Expired', 'Expired', 'Aman'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bahan Makanan',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark)),
                      SizedBox(height: 2),
                      Text('Kelola stok bahan makanamu disini',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textGrey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Scan & Input Buttons ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddFoodScreen(userId: widget.userId))),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Scan Barcode',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddFoodScreen(userId: widget.userId))),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined,
                                color: AppTheme.textDark, size: 20),
                            SizedBox(width: 8),
                            Text('Input Manual',
                                style: TextStyle(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Filter Chips ─────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final selected = f == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryGreen
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryGreen
                                : AppTheme.dividerColor,
                          ),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textGrey)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<FoodItem>>(
                stream: _firestoreService.getFoodStream(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen));
                  }

                  var items = snapshot.data ?? [];

                  // Filter
                  if (_selectedFilter == 'Hampir Expired') {
                    items = items
                        .where((i) => i.isExpiringSoon && !i.isExpired)
                        .toList();
                  } else if (_selectedFilter == 'Expired') {
                    items = items.where((i) => i.isExpired).toList();
                  } else if (_selectedFilter == 'Aman') {
                    items = items
                        .where((i) =>
                            !i.isExpired && !i.isExpiringSoon)
                        .toList();
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2_outlined,
                                size: 40, color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(height: 16),
                          const Text('Belum ada bahan makanan',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          const Text('Tambahkan bahan makananmu sekarang',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textGrey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        // Tambah bahan button di bawah list
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AddFoodScreen(
                                        userId: widget.userId))),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppTheme.primaryGreen,
                                    style: BorderStyle.solid),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: AppTheme.primaryGreen, size: 20),
                                  SizedBox(width: 6),
                                  Text('Tambah Bahan Lainnya',
                                      style: TextStyle(
                                          color: AppTheme.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final item = items[index];
                      return _InventoryCard(
                        item: item,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(
                                    item: item, userId: widget.userId))),
                        onDelete: () => _deleteItem(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(FoodItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Bahan'),
        content: Text('Hapus "${item.foodName}" dari inventaris?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppTheme.statusCritical))),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.removeFood(item.foodId);
    }
  }
}

class _InventoryCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _InventoryCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.getExpiryStatus();
    final color = AppTheme.getExpiryColor(status);
    final days = item.getDaysToExpiry();

    String daysLabel;
    if (days < 0) {
      daysLabel = 'Expired';
    } else if (days == 0) {
      daysLabel = 'Hari ini';
    } else {
      daysLabel = '$days Hari Lagi';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppTheme.getCategoryIcon(item.category),
                  color: color, size: 24),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.foodName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(item.category,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                    const Text(' • ',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                    const Text('Barcode',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ]),
                ],
              ),
            ),

            // Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(daysLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Text(item.category,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
