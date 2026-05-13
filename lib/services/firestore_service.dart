import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../models/recipe_log.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── FOOD ITEM CRUD ───────────────────────────────────────────────────────

  /// Tambah makanan baru ke Firestore
  Future<void> addFood(FoodItem item) async {
    await _db
        .collection('food_items')
        .doc(item.foodId)
        .set(item.toJson());
  }

  /// Hapus makanan dari Firestore
  Future<void> removeFood(String foodId) async {
    await _db.collection('food_items').doc(foodId).delete();
  }

  /// Update data makanan
  Future<void> updateFood(FoodItem item) async {
    await _db
        .collection('food_items')
        .doc(item.foodId)
        .update(item.toJson());
  }

  /// Stream semua makanan milik user (real-time)
  Stream<List<FoodItem>> getFoodStream(String userId) {
    return _db
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => FoodItem.fromJson(doc.data()))
              .toList();
          // Sort di sisi client — tidak butuh composite index Firestore
          items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          return items;
        });
  }

  /// Ambil makanan yang akan kedaluwarsa dalam N hari ke depan
  Future<List<FoodItem>> getExpiringSoon(String userId, {int days = 3}) async {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));

    final snapshot = await _db
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(limit))
        .get();

    return snapshot.docs
        .map((doc) => FoodItem.fromJson(doc.data()))
        .toList();
  }

  // ─── RECIPE LOG ───────────────────────────────────────────────────────────

  /// Simpan riwayat resep
  Future<void> saveRecipeLog(RecipeLog log) async {
    await _db
        .collection('recipe_logs')
        .doc(log.recipeId)
        .set(log.toJson());
  }

  /// Stream riwayat resep user
  Stream<List<RecipeLog>> getRecipeLogStream(String userId) {
    return _db
        .collection('recipe_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final logs = snapshot.docs
              .map((doc) => RecipeLog.fromJson(doc.data()))
              .toList();
          // Sort terbaru duluan, di sisi client
          logs.sort((a, b) => b.tanggalDibuat.compareTo(a.tanggalDibuat));
          return logs;
        });
  }
}
