import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String foodId;
  final String foodName;
  final DateTime expiryDate;
  final String category;
  final String? barcode;
  final String userId;
  final String statusNotifikasi;

  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.expiryDate,
    required this.category,
    this.barcode,
    required this.userId,
    this.statusNotifikasi = 'active',
  });

  /// Hitung sisa hari sebelum kedaluwarsa
  int getDaysToExpiry() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// Status warna berdasarkan sisa hari
  String getExpiryStatus() {
    final days = getDaysToExpiry();
    if (days < 0) return 'expired';
    if (days <= 3) return 'critical'; // merah
    if (days <= 7) return 'warning';  // kuning
    return 'good';                    // hijau
  }

  bool get isExpired => getDaysToExpiry() < 0;
  bool get isExpiringSoon => getDaysToExpiry() >= 0 && getDaysToExpiry() <= 3;

  /// Konversi ke JSON untuk Firestore
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'category': category,
      'barcode': barcode,
      'userId': userId,
      'statusNotifikasi': statusNotifikasi,
    };
  }

  /// Buat FoodItem dari dokumen Firestore
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      category: json['category'] ?? 'Lainnya',
      barcode: json['barcode'],
      userId: json['userId'] ?? '',
      statusNotifikasi: json['statusNotifikasi'] ?? 'active',
    );
  }

  FoodItem copyWith({
    String? foodId,
    String? foodName,
    DateTime? expiryDate,
    String? category,
    String? barcode,
    String? userId,
    String? statusNotifikasi,
  }) {
    return FoodItem(
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      userId: userId ?? this.userId,
      statusNotifikasi: statusNotifikasi ?? this.statusNotifikasi,
    );
  }
}
