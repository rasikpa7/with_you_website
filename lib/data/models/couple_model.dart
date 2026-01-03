import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String coupleId;
  final String inviteCode;
  final List<String> userIds;
  final DateTime createdAt;

  CoupleModel({
    required this.coupleId,
    required this.inviteCode,
    required this.userIds,
    required this.createdAt,
  });

  // From Firestore
  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CoupleModel(
      coupleId: doc.id,
      inviteCode: data['inviteCode'] ?? '',
      userIds: List<String>.from(data['userIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'inviteCode': inviteCode,
      'userIds': userIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isComplete => userIds.length == 2;
}
