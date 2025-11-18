import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _groupsCollection = 'groups';

  String? _telegramUserId;

  void setTelegramUserId(String userId) {
    _telegramUserId = userId;
    print('Telegram User ID set: $userId');
  }

  Stream<List<Map<String, dynamic>>> getGroups() {
    try {
      var query = _firestore
          .collection(_groupsCollection)
          .orderBy('createdAt', descending: true);

      if (_telegramUserId != null) {
        query = query.where('userId', isEqualTo: _telegramUserId);
      }

      return query
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

  Future<void> createGroup(String name) async {
    try {
      await _firestore.collection(_groupsCollection).add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': _telegramUserId,
      });
      print('Group created successfully: $name for user: $_telegramUserId');
    } catch (e) {
      print('Error creating group: $e');
      throw Exception('Ошибка при создании группы: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
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
}
