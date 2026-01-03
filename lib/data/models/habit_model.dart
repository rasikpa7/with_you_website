import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String habitId;
  final String coupleId;
  final String name;
  final String frequency; // 'daily' or 'weekly'
  final int points;
  final DateTime createdAt;

  HabitModel({
    required this.habitId,
    required this.coupleId,
    required this.name,
    required this.frequency,
    required this.points,
    required this.createdAt,
  });

  // From Firestore
  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      habitId: doc.id,
      coupleId: data['coupleId'] ?? '',
      name: data['name'] ?? '',
      frequency: data['frequency'] ?? 'daily',
      points: data['points'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'coupleId': coupleId,
      'name': name,
      'frequency': frequency,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
