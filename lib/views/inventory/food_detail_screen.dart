import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/food_item.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem item;
  final String userId;

  const FoodDetailScreen({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.getExpiryStatus();
    final color = AppTheme.getExpiryColor(status);
    final days = item.getDaysToExpiry();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Makanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        AppTheme.getCategoryIcon(item.category),
                        color: color,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.foodName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        days < 0
                            ? 'Sudah Kedaluwarsa'
                            : days == 0
                                ? 'Kedaluwarsa Hari Ini'
                                : '$days Hari Lagi',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detail info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Kategori',
                      value: item.category,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Kedaluwarsa',
                      value: DateFormat('dd MMMM yyyy', 'id_ID')
                          .format(item.expiryDate),
                    ),
                    if (item.barcode != null) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.barcode_reader,
                        label: 'Barcode',
                        value: item.barcode!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Makanan'),
        content: Text('Hapus "${item.foodName}" dari inventaris?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppTheme.statusCritical)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await FirestoreService().removeFood(item.foodId);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
