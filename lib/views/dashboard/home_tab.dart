import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/food_item.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../inventory/add_food_screen.dart';
import '../inventory/food_detail_screen.dart';

class HomeTab extends StatelessWidget {
  final String userId;
  const HomeTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Pengguna';
    final firstName = displayName.split(' ').first;
    final firestoreService = FirestoreService();
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: StreamBuilder<List<FoodItem>>(
          stream: firestoreService.getFoodStream(userId),
          builder: (context, snapshot) {
            final allItems = snapshot.data ?? [];
            final expiringSoon = allItems
                .where((i) => i.isExpiringSoon && !i.isExpired)
                .toList();
            final expired = allItems.where((i) => i.isExpired).toList();
            final safe = allItems
                .where((i) => !i.isExpired && !i.isExpiringSoon)
                .toList();

            // Hitung waste score (0-100, makin tinggi makin baik)
            final wasteScore = allItems.isEmpty
                ? 100
                : ((safe.length / allItems.length) * 100).round();

            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeader(
                      context, firstName, greeting, now, displayName),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Waste Score Card ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _WasteScoreCard(
                      score: wasteScore,
                      totalItems: allItems.length,
                      expiredCount: expired.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Stats Row ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StatMiniCard(
                          label: 'Total Stok',
                          value: '${allItems.length}',
                          icon: Icons.inventory_2_outlined,
                          color: AppTheme.primaryGreen,
                          bgColor: AppTheme.lightGreen,
                        ),
                        const SizedBox(width: 10),
                        _StatMiniCard(
                          label: 'Hampir Exp.',
                          value: '${expiringSoon.length}',
                          icon: Icons.warning_amber_outlined,
                          color: const Color(0xFFFF9800),
                          bgColor: const Color(0xFFFFF3E0),
                        ),
                        const SizedBox(width: 10),
                        _StatMiniCard(
                          label: 'Expired',
                          value: '${expired.length}',
                          icon: Icons.cancel_outlined,
                          color: AppTheme.statusCritical,
                          bgColor: const Color(0xFFFFEBEE),
                        ),
                        const SizedBox(width: 10),
                        _StatMiniCard(
                          label: 'Aman',
                          value: '${safe.length}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF1976D2),
                          bgColor: const Color(0xFFE3F2FD),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Alert Banner ─────────────────────────────────────
                if (expiringSoon.isNotEmpty || expired.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _AlertBanner(
                        expiringSoon: expiringSoon,
                        expired: expired,
                      ),
                    ),
                  ),

                if (expiringSoon.isNotEmpty || expired.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Tips Harian ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _DailyTipCard(dayOfYear: now.dayOfYear),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Stok Terbaru Header ──────────────────────────────
                if (allItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Stok Terbaru',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark)),
                          Text('${allItems.length} item',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textGrey)),
                        ],
                      ),
                    ),
                  ),

                if (allItems.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // ── Stok List (max 4) ────────────────────────────────
                if (allItems.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = allItems[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: _StockItemCard(
                            item: item,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(
                                    item: item, userId: userId),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount:
                          allItems.length > 4 ? 4 : allItems.length,
                    ),
                  ),

                // ── Empty State ──────────────────────────────────────
                if (allItems.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: _EmptyStockCard(userId: userId),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AddFoodScreen(userId: userId)),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Stok',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName, String greeting,
      DateTime now, String displayName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text(firstName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              // Notif
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tanggal & quote
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.eco, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('ZeroWaste',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 11) return 'Selamat Pagi 🌤️';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }
}

// ── Extension ────────────────────────────────────────────────────────────────
extension DateTimeExt on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays;
  }
}

// ── Waste Score Card ─────────────────────────────────────────────────────────
class _WasteScoreCard extends StatelessWidget {
  final int score;
  final int totalItems;
  final int expiredCount;

  const _WasteScoreCard({
    required this.score,
    required this.totalItems,
    required this.expiredCount,
  });

  String get _scoreLabel {
    if (score >= 90) return 'Luar Biasa! 🏆';
    if (score >= 70) return 'Bagus! 👍';
    if (score >= 50) return 'Cukup Baik 😊';
    return 'Perlu Perhatian ⚠️';
  }

  Color get _scoreColor {
    if (score >= 90) return AppTheme.primaryGreen;
    if (score >= 70) return const Color(0xFF66BB6A);
    if (score >= 50) return const Color(0xFFFF9800);
    return AppTheme.statusCritical;
  }

  String get _scoreDesc {
    if (score >= 90) return 'Stok makananmu sangat terjaga!';
    if (score >= 70) return 'Terus jaga stok makananmu.';
    if (score >= 50) return 'Ada beberapa bahan yang perlu diperhatikan.';
    return 'Segera gunakan bahan yang hampir expired!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _scoreColor.withValues(alpha: 0.12),
            _scoreColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // Score circle
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    backgroundColor:
                        _scoreColor.withValues(alpha: 0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_scoreColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text('$score',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Waste Score',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_scoreLabel,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor)),
                const SizedBox(height: 4),
                Text(_scoreDesc,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMedium)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 12, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text('$totalItems item tersimpan',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textGrey)),
                  if (expiredCount > 0) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.cancel_outlined,
                        size: 12, color: AppTheme.statusCritical),
                    const SizedBox(width: 4),
                    Text('$expiredCount expired',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.statusCritical)),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Mini Card ────────────────────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Alert Banner ──────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final List<FoodItem> expiringSoon;
  final List<FoodItem> expired;

  const _AlertBanner({
    required this.expiringSoon,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = expired.isNotEmpty;
    final color =
        isExpired ? AppTheme.statusCritical : const Color(0xFFFF9800);
    final bgColor =
        isExpired ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0);
    final borderColor = isExpired
        ? const Color(0xFFEF9A9A)
        : const Color(0xFFFFCC80);
    final items = isExpired ? expired : expiringSoon;
    final title = isExpired
        ? '${expired.length} Bahan Sudah Expired!'
        : '${expiringSoon.length} Bahan Hampir Kedaluwarsa!';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired ? Icons.cancel : Icons.warning_amber_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color)),
                const SizedBox(height: 4),
                ...items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(children: [
                        Icon(Icons.circle, size: 5, color: color),
                        const SizedBox(width: 6),
                        Text(
                          item.getDaysToExpiry() < 0
                              ? '${item.foodName} — sudah expired'
                              : '${item.foodName} — ${item.getDaysToExpiry()} hari lagi',
                          style: TextStyle(
                              fontSize: 12,
                              color: color.withValues(alpha: 0.85)),
                        ),
                      ]),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Tip Card ────────────────────────────────────────────────────────────
class _DailyTipCard extends StatelessWidget {
  final int dayOfYear;

  const _DailyTipCard({required this.dayOfYear});

  static const List<Map<String, String>> _tips = [
    {
      'icon': '🥦',
      'title': 'Simpan sayuran dengan benar',
      'desc':
          'Bungkus sayuran dengan kertas sebelum masuk kulkas agar lebih tahan lama.',
    },
    {
      'icon': '🧊',
      'title': 'Bekukan sebelum expired',
      'desc':
          'Daging dan ikan bisa dibekukan hingga 3 bulan. Tandai tanggal pembekuan!',
    },
    {
      'icon': '🍋',
      'title': 'FIFO — First In, First Out',
      'desc':
          'Selalu gunakan bahan yang lebih lama dibeli terlebih dahulu.',
    },
    {
      'icon': '📦',
      'title': 'Cek stok sebelum belanja',
      'desc':
          'Periksa inventaris sebelum ke supermarket agar tidak membeli ganda.',
    },
    {
      'icon': '🌿',
      'title': 'Manfaatkan sisa bahan',
      'desc':
          'Batang brokoli, kulit wortel, dan tulang ayam bisa dijadikan kaldu.',
    },
    {
      'icon': '❄️',
      'title': 'Suhu kulkas yang tepat',
      'desc':
          'Atur suhu kulkas di 1–4°C untuk menjaga kesegaran bahan makanan.',
    },
    {
      'icon': '🫙',
      'title': 'Gunakan wadah kedap udara',
      'desc':
          'Simpan bahan kering dalam toples kedap udara agar tidak lembab.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[dayOfYear % _tips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(tip['icon']!,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Tips Hari Ini',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(tip['title']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(tip['desc']!,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stock Item Card ───────────────────────────────────────────────────────────
class _StockItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _StockItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = item.getExpiryStatus();
    final color = AppTheme.getExpiryColor(status);
    final days = item.getDaysToExpiry();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppTheme.getCategoryIcon(item.category),
                  color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.foodName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(item.category,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textGrey)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                days < 0
                    ? 'Expired'
                    : days == 0
                        ? 'Hari ini'
                        : '$days hari',
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Stock Card ──────────────────────────────────────────────────────────
class _EmptyStockCard extends StatelessWidget {
  final String userId;
  const _EmptyStockCard({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_shopping_cart_outlined,
                size: 36, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text('Stok Masih Kosong',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 6),
          const Text(
            'Mulai tambahkan bahan makananmu\nagar tidak ada yang terbuang sia-sia.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppTheme.textGrey, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddFoodScreen(userId: userId)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Sekarang'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 44),
            ),
          ),
        ],
      ),
    );
  }
}
