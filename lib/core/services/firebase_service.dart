import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _groupsCollection = 'groups';
  final String _expensesCollection = 'expenses';

  Stream<List<Map<String, dynamic>>> getGroups(String userId) {
    try {
      return _firestore
          .collection(_groupsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['name'] ?? '',
                'createdAt': data['createdAt'],
                'userId': data['userId'],
                'sourceGroupId': data['sourceGroupId'] ?? doc.id,
                'ownerId': data['ownerId'] ?? data['userId'],
                'member': data['member'],
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
      final docRef = _firestore.collection(_groupsCollection).doc();
      await docRef.set({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'ownerId': userId,
        'sourceGroupId': docRef.id,
        'member': {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
        },
      });

      print('Group created successfully: $name with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating group: $e');
      throw Exception('Ошибка при создании группы: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final batch = _firestore.batch();
      final groupRef = _firestore.collection(_groupsCollection).doc(groupId);
      batch.delete(groupRef);

      final sharedDocs = await _firestore
          .collection(_groupsCollection)
          .where('sourceGroupId', isEqualTo: groupId)
          .get();

      for (final doc in sharedDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
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

      final sharedDocs = await _firestore
          .collection(_groupsCollection)
          .where('sourceGroupId', isEqualTo: groupId)
          .get();

      for (final doc in sharedDocs.docs) {
        if (doc.id == groupId) continue;
        await doc.reference.update({'name': newName});
      }
      print('Group updated successfully: $groupId');
    } catch (e) {
      print('Error updating group: $e');
      throw Exception('Ошибка при обновлении группы: $e');
    }
  }

  Future<Map<String, dynamic>?> getGroupById(String groupId) async {
    try {
      final doc = await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'createdAt': data['createdAt'],
        'userId': data['userId'],
        'expensesId': data['sourceGroupId'] ?? doc.id,
        'expensesName': data['name'] ?? '',
        'sourceGroupId': data['sourceGroupId'] ?? doc.id,
        'ownerId': data['ownerId'] ?? data['userId'],
        'member': data['member'],
      };
    } catch (e) {
      print('Error getting group by id: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMembers(String sourceGroupId) {
    try {
      return _firestore
          .collection(_groupsCollection)
          .where('sourceGroupId', isEqualTo: sourceGroupId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              final member = data['member'] ?? {};
              final firstName = member['firstName'] ?? '';
              final lastName = member['lastName'] ?? '';
              final username = member['username'];
              return {
                'id': doc.id,
                'userId': data['userId'],
                'firstName': firstName,
                'lastName': lastName,
                'username': username,
                'isOwner':
                    (data['ownerId'] ?? data['userId']) == data['userId'],
              };
            }).toList();
          })
          .handleError((error) {
            print('Error getting group members: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getGroupMembers: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<bool> linkUserToGroup({
    required String sourceGroupId,
    required String userId,
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    try {
      final groupDoc = await _firestore
          .collection(_groupsCollection)
          .doc(sourceGroupId)
          .get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        return false;
      }

      final data = groupDoc.data()!;
      if ((data['userId'] ?? '') == userId) {
        return true;
      }

      final existing = await _firestore
          .collection(_groupsCollection)
          .where('userId', isEqualTo: userId)
          .where('sourceGroupId', isEqualTo: sourceGroupId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return true;
      }

      final docRef = _firestore.collection(_groupsCollection).doc();
      await docRef.set({
        'name': data['name'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'sourceGroupId': data['sourceGroupId'] ?? sourceGroupId,
        'ownerId': data['ownerId'] ?? data['userId'],
        'invitedBy': data['ownerId'] ?? data['userId'],
        'member': {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
        },
      });

      return true;
    } catch (e) {
      print('Error linking user to group: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getExpenses(String id) {
    try {
      return _firestore
          .collection(_expensesCollection)
          .where('id', isEqualTo: id)
          .snapshots()
          .map((snapshot) {
            final expenses = snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc.data()['name'] ?? '',
                'amount': doc.data()['amount'] ?? '0',
                'createdAt': doc.data()['createdAt'],
              };
            }).toList();
            expenses.sort((a, b) {
              final aTime = a['createdAt'] as Timestamp?;
              final bTime = b['createdAt'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });
            return expenses;
          })
          .handleError((error) {
            print('Error getting expenses: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getExpenses: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<String> createExpenses({
    required String name,
    required String id,
    required String expense,
    String? amount,
  }) async {
    try {
      final docRef = await _firestore.collection(_expensesCollection).add({
        'name': name,
        'amount': amount ?? '0',
        'createdAt': FieldValue.serverTimestamp(),
        'id': id,
      });

      print('Expense created successfully: $name with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating expense: $e');
      throw Exception('Ошибка при добавлени расхода: $e');
    }
  }

  Future<void> deleteExpenses(String id) async {
    try {
      _firestore.collection(_expensesCollection).doc(id);

      await _firestore.collection(_expensesCollection).doc(id).delete();
      print('Expense deleted successfully: $id');
    } catch (e) {
      print('Error deleting expense: $e');
      throw Exception('Ошибка при удалении расхода: $e');
    }
  }

  Future<void> updateExpenses(String id, String newName) async {
    try {
      await _firestore.collection(_expensesCollection).doc(id).update({
        'name': newName,
      });
      print('Expense updated successfully: $id');
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Ошибка при обновлении расхода: $e');
    }
  }
}
