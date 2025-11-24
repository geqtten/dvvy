import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _groupsCollection = 'groups';
  final String _membersCollection = 'members';

  Stream<List<Map<String, dynamic>>> getGroups(String userId) {
    try {
      return _firestore
          .collection(_groupsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc.data()['name'] ?? '',
                'createdAt': doc.data()['createdAt'],
                'userId': doc.data()['userId'],
              };
            }).toList();
          })
          .handleError((error) {
            print('Error getting groups: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getGroups: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<String> createGroup({
    required String name,
    required String userId,
    String? username,
    required String firstName,
    String? lastName,
  }) async {
    try {
      final docRef = await _firestore.collection(_groupsCollection).add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      await addUserToGroup(
        groupId: docRef.id,
        userId: userId,
        username: username,
        firstName: firstName,
      );

      print('Group created successfully: $name with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating group: $e');
      throw Exception('Ошибка при создании группы: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final membersSnapshot = await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .get();

      for (var doc in membersSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection(_groupsCollection).doc(groupId).delete();
      print('Group deleted successfully: $groupId');
    } catch (e) {
      print('Error deleting group: $e');
      throw Exception('Ошибка при удалении группы: $e');
    }
  }

  Future<void> updateGroup(String groupId, String newName) async {
    try {
      await _firestore.collection(_groupsCollection).doc(groupId).update({
        'name': newName,
      });
      print('Group updated successfully: $groupId');
    } catch (e) {
      print('Error updating group: $e');
      throw Exception('Ошибка при обновлении группы: $e');
    }
  }

  Future<void> addUserToGroup({
    required String groupId,
    required String userId,
    required String firstName,
    required String? username,
  }) async {
    final groupRef = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("members")
        .doc(userId);

    final exists = await groupRef.get();

    if (!exists.exists) {
      await groupRef.set({
        'firstName': firstName,
        'username': username,
        'isOwner': false,
        'joinedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getMembers(String groupId) {
    try {
      return _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .orderBy('joinedAt')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'telegramUserId': data['telegramUserId'] ?? '',
                'username': data['username'],
                'firstName': data['firstName'] ?? '',
                'lastName': data['lastName'],
                'isOwner': data['isOwner'] ?? false,
                'joinedAt': data['joinedAt'],
              };
            }).toList();
          })
          .handleError((error) {
            print('Error getting members: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getMembers: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<void> removeMember(String groupId, String telegramUserId) async {
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(telegramUserId)
          .delete();
      print('Member removed: $telegramUserId');
    } catch (e) {
      print('Error removing member: $e');
      throw Exception('Ошибка при удалении участника: $e');
    }
  }

  Future<bool> isMember(String groupId, String telegramUserId) async {
    try {
      final doc = await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .doc(telegramUserId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking membership: $e');
      return false;
    }
  }

  Future<int> getMemberCount(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_membersCollection)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting member count: $e');
      return 0;
    }
  }
}
