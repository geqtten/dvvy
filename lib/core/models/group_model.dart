import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/core/models/member_model.dart';

class Group {
  final String id;
  final String name;
  final String adminId;
  final Map<String, Member> members;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.adminId,
    required this.members,
    required this.createdAt,
  });

  bool isAdmin(String userId) => adminId == userId;
  bool isMember(String userId) => members.containsKey(userId);

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      members:
          (data['members'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Member.fromMap(value)),
          ) ??
          {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'adminId': adminId,
      'members': members.map((key, value) => MapEntry(key, value.toMap())),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
