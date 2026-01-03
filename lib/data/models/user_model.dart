import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? coupleId;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.coupleId,
    required this.createdAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      coupleId: data['coupleId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'coupleId': coupleId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CopyWith
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? coupleId,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      coupleId: coupleId ?? this.coupleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
