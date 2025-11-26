import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// A small wrapper around Firebase Auth + Firestore for this app.
class FirebaseAuthService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign in with email/password and return the resolved role ('admin'|'member'|other).
  /// Throws [fb.FirebaseAuthException] for auth failures.
  static Future<String> signInWithEmailPassword(
      String email, String password) async {
    final cleanedEmail = email.trim();

    final fb.UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: cleanedEmail,
      password: password,
    );

    final fb.User? user = cred.user;
    if (user == null) {
      throw Exception('Failed to sign in: no user returned');
    }

    // Fetch role from Firestore users collection. First try doc by UID, then fallback to query by email.
    String? role;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        role = data != null && data['role'] != null
            ? data['role'].toString()
            : null;
      }
    } catch (_) {
      // ignore and fallback to query method
    }

    if (role == null) {
      final q = await _db
          .collection('users')
          .where('email', isEqualTo: cleanedEmail)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final d = q.docs.first.data();
        role = d['role'] != null ? d['role'].toString() : null;
      }
    }

    return (role ?? 'member').toLowerCase();
  }

  /// Get current signed-in user's role (or null if not signed-in or not found)
  static Future<String?> getCurrentUserRole() async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data != null && data['role'] != null
            ? data['role'].toString().toLowerCase()
            : null;
      }

      final q = await _db
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final d = q.docs.first.data();
        return d['role'] != null ? d['role'].toString().toLowerCase() : null;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
