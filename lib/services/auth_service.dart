import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream status login user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// User yang sedang login
  User? get currentUser => _auth.currentUser;

  /// Register dengan email & password
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    await user.updateDisplayName(name);

    final userModel = UserModel(
      userId: user.uid,
      name: name,
      email: email,
    );

    // Simpan data user ke Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toJson());

    return userModel;
  }

  /// Login dengan email & password
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Ambil data user dari Firestore
  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
}
