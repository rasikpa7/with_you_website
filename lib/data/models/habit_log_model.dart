import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLogModel {
  final String logId;
  final String userId;
  final String habitId;
  final DateTime date;
  final int points;
  final DateTime createdAt;

  HabitLogModel({
    required this.logId,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.points,
    required this.createdAt,
  });

  // From Firestore
  factory HabitLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HabitLogModel(
      logId: doc.id,
      userId: data['userId'] ?? '',
      habitId: data['habitId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'habitId': habitId,
      'date': Timestamp.fromDate(date),
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
