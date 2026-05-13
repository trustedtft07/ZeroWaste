import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/food_item.dart';
import '../../models/recipe_log.dart';
import '../../services/firestore_service.dart';
import '../../services/recipe_service.dart';
import '../../utils/app_theme.dart';
import 'recipe_result_screen.dart';

class RecipeScreen extends StatefulWidget {
  final String userId;
  const RecipeScreen({super.key, required this.userId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _recipeService = RecipeService();
  final Set<String> _selectedFoodIds = {};
  bool _isGenerating = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe(List<FoodItem> allItems) async {
    if (_selectedFoodIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih minimal 1 bahan'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final selected = allItems
          .where((i) => _selectedFoodIds.contains(i.foodId))
          .toList();
      final ingredients = selected.map((i) => i.foodName).toList();
      final result = await _recipeService.generateRecipe(ingredients);

      if (!result.startsWith('⚠️')) {
        await _firestoreService.saveRecipeLog(RecipeLog(
          recipeId: const Uuid().v4(),
          userId: widget.userId,
          judulResep: 'Resep dari ${ingredients.join(', ')}',
          isiResep: result,
          tanggalDibuat: DateTime.now(),
        ));
      }

      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RecipeResultScreen(
                    ingredients: ingredients, recipeText: result)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RecipeResultScreen(
                    ingredients: const [],
                    recipeText:
                        '⚠️ Terjadi kesalahan.\n\n${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Tanya Resep ',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark)),
                          Text('✨',
                              style: TextStyle(fontSize: 22)),
                        ]),
                        SizedBox(height: 2),
                        Text('Support by Groq AI',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tab Bar ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textGrey,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Pilih Bahan'),
                  Tab(text: 'Riwayat Resep'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSelectIngredients(),
                  _buildRecipeHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectIngredients() {
    return StreamBuilder<List<FoodItem>>(
      stream: _firestoreService.getFoodStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        final allItems = snapshot.data ?? [];

        if (allItems.isEmpty) {
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
                const Text('Tambahkan dulu di menu Inventaris',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          );
        }

        // Expiring soon first
        final sorted = [...allItems]
          ..sort((a, b) => a.getDaysToExpiry().compareTo(b.getDaysToExpiry()));

        // Show expiring soon alert if any
        final expiringSoon =
            sorted.where((i) => i.isExpiringSoon && !i.isExpired).toList();

        return Column(
          children: [
            if (expiringSoon.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF9A9A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.statusCritical, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${expiringSoon.map((i) => i.foodName).take(2).join(', ')} hampir kedaluwarsa!',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.statusCritical,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.statusCritical,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Pakai Bahan Ini',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final item = sorted[index];
                  final isSelected = _selectedFoodIds.contains(item.foodId);
                  final color = AppTheme.getExpiryColor(item.getExpiryStatus());
                  final days = item.getDaysToExpiry();

                  return GestureDetector(
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selectedFoodIds.remove(item.foodId);
                      } else {
                        _selectedFoodIds.add(item.foodId);
                      }
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : AppTheme.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.textDark)),
                                const SizedBox(height: 2),
                                Text(
                                  days < 0
                                      ? 'Sudah kedaluwarsa'
                                      : days == 0
                                          ? 'Kedaluwarsa hari ini'
                                          : '$days hari lagi',
                                  style: TextStyle(
                                      color: color, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : AppTheme.dividerColor,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Generate button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton(
                onPressed: _isGenerating ? null : () => _generateRecipe(allItems),
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _selectedFoodIds.isEmpty
                            ? 'Pilih Bahan Dulu'
                            : 'Generate Resep (${_selectedFoodIds.length} bahan)'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipeHistory() {
    return StreamBuilder<List<RecipeLog>>(
      stream: _firestoreService.getRecipeLogStream(widget.userId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
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
                  child: const Icon(Icons.history,
                      size: 40, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 16),
                const Text('Belum ada riwayat resep',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant_menu,
                      color: AppTheme.primaryGreen, size: 22),
                ),
                title: Text(log.judulResep,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                    '${log.tanggalDibuat.day}/${log.tanggalDibuat.month}/${log.tanggalDibuat.year}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textGrey)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppTheme.textGrey),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RecipeResultScreen(
                            ingredients: const [],
                            recipeText: log.isiResep,
                            title: log.judulResep))),
              ),
            );
          },
        );
      },
    );
  }
}
