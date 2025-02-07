import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/users_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier()
      : super(UserModel(
          userId: '',
          email: '',
          displayName: '',
          profileCompleted: false,
          role: '',
        )) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        state = UserModel(
          userId: '',
          email: '',
          displayName: '',
          profileCompleted: false,
          role: '',
        );
      }
    });
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        state = UserModel(
          profileCompleted: data['profileCompleted'],
          additionalData: data['additionalData'],
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> updateUserProfile({
    String? username,
    String? userType,
    String? profileImageUrl,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final uid = state.userId;
      if (uid == null) return;

      final updates = {
        if (username != null) 'username': username,
        if (userType != null) 'userType': userType,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (additionalData != null) 'additionalData': additionalData,
      };

      await _firestore.collection('users').doc(uid).update(updates);

      state = state.copyWith(
        displayName: username ?? state.displayName,
        role: userType ?? state.role,
        additionalData: additionalData ?? state.additionalData,
      );
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  String? get username => state.displayName;
  String? get userType => state.role;
  bool get isAuthenticated => state.userId != '';
  bool get isInvestor => state.role == 'investor';
  bool get isBusiness => state.role == 'business';
}
