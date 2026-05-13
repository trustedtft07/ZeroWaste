import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeLog {
  final String recipeId;
  final String userId;
  final String judulResep;
  final String isiResep;
  final DateTime tanggalDibuat;

  RecipeLog({
    required this.recipeId,
    required this.userId,
    required this.judulResep,
    required this.isiResep,
    required this.tanggalDibuat,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'judulResep': judulResep,
      'isiResep': isiResep,
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat),
    };
  }

  factory RecipeLog.fromJson(Map<String, dynamic> json) {
    return RecipeLog(
      recipeId: json['recipeId'] ?? '',
      userId: json['userId'] ?? '',
      judulResep: json['judulResep'] ?? '',
      isiResep: json['isiResep'] ?? '',
      tanggalDibuat: (json['tanggalDibuat'] as Timestamp).toDate(),
    );
  }
}
