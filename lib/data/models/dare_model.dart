import 'package:cloud_firestore/cloud_firestore.dart';

class DareModel {
  final String dareId;
  final String content;
  final String type; // 'dare' or 'question'

  DareModel({
    required this.dareId,
    required this.content,
    required this.type,
  });

  // From Firestore
  factory DareModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DareModel(
      dareId: doc.id,
      content: data['content'] ?? '',
      type: data['type'] ?? 'dare',
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'type': type,
    };
  }
}
