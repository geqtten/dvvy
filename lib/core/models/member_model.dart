import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String userId;
  final String role; // 'admin' или 'member'
  final DateTime joinedAt;

  Member({required this.userId, required this.role, required this.joinedAt});

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      userId: map['userId'] ?? '',
      role: map['role'] ?? 'member',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}
