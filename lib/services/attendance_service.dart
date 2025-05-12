import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add attendance for a subject
  Future<void> addAttendance(String subject, bool present) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .add({
        'subject': subject,
        'present': present,
        'date': DateTime.now(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding attendance: $e');
      rethrow;
    }
  }

  // Get all attendances grouped by subject
  Stream<QuerySnapshot> getAttendanceBySubject() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get attendance statistics by subject
  Future<Map<String, Map<String, dynamic>>> getAttendanceStats() async {
    String userId = _auth.currentUser!.uid;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .get();

    Map<String, Map<String, dynamic>> stats = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String subject = data['subject'];
      bool present = data['present'];

      if (!stats.containsKey(subject)) {
        stats[subject] = {
          'total': 0,
          'present': 0,
          'percentage': 0.0,
        };
      }

      stats[subject]!['total']++;
      if (present) {
        stats[subject]!['present']++;
      }

      // Calculate percentage
      stats[subject]!['percentage'] =
          (stats[subject]!['present'] / stats[subject]!['total']) * 100;
    }

    return stats;
  }
}