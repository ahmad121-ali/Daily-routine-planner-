import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _taskCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  // Updated logic to store ALL ritual details permanently
  Future<void> addTask({
    required String title,
    required String category,
    required String time,
    required String focus,
    required String period,
    required bool isTimed,
    int? duration,
    String? imageUrl,
    List<String>? techniques,
  }) {
    return _taskCollection.add({
      'title': title,
      'category': category,
      'time': time,
      'focus': focus,
      'period': period,
      'isTimed': isTimed,
      'duration': duration,
      'imageUrl': imageUrl,
      'techniques': techniques,
      'isCompleted': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTasksStream() {
    try {
      return _taskCollection.orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      return const Stream.empty();
    }
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) {
    return _taskCollection.doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTask(String taskId) {
    return _taskCollection.doc(taskId).delete();
  }
}
