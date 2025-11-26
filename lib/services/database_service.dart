// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// A service class for handling all Firestore database operations
class DatabaseService {
  // Singleton pattern
  static DatabaseService? _instance;
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COLLECTION REFERENCES ====================

  /// Users collection
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  /// Notices collection
  CollectionReference<Map<String, dynamic>> get noticesCollection =>
      _firestore.collection('notices');

  /// Maintenance records collection
  CollectionReference<Map<String, dynamic>> get maintenanceCollection =>
      _firestore.collection('maintenance');

  /// Payments collection
  CollectionReference<Map<String, dynamic>> get paymentsCollection =>
      _firestore.collection('payments');

  /// Complaints collection
  CollectionReference<Map<String, dynamic>> get complaintsCollection =>
      _firestore.collection('complaints');

  /// Society settings collection
  CollectionReference<Map<String, dynamic>> get settingsCollection =>
      _firestore.collection('settings');

  /// Events collection
  CollectionReference<Map<String, dynamic>> get eventsCollection =>
      _firestore.collection('events');

  /// Visitors collection
  CollectionReference<Map<String, dynamic>> get visitorsCollection =>
      _firestore.collection('visitors');

  // ==================== GENERIC OPERATIONS ====================

  /// Add a document to any collection
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add document to $collection: $e');
    }
  }

  /// Update a document in any collection
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document in $collection: $e');
    }
  }

  /// Delete a document from any collection
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document from $collection: $e');
    }
  }

  /// Get a document from any collection
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document from $collection: $e');
    }
  }

  /// Get all documents from any collection
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to get documents from $collection: $e');
    }
  }

  /// Stream documents from any collection
  Stream<List<Map<String, dynamic>>> documentsStream(String collection, {String? orderBy, bool descending = true}) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList()
    );
  }

  // ==================== USER OPERATIONS ====================

  /// Create a new user in Firestore
  Future<void> createUser(User user) async {
    try {
      print('Creating user in Firestore: ${user.id}');
      print('User data: ${user.toJson()}');
      await usersCollection.doc(user.id).set(user.toJson());
      print('User created successfully in Firestore');
    } catch (e) {
      print('Failed to create user in Firestore: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      print('Fetching user from Firestore: $userId');
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        print('Raw user data from Firestore: ${doc.data()}');
        try {
          final user = User.fromJson(doc.data()!);
          print('Successfully parsed user: ${user.username}');
          return user;
        } catch (parseError) {
          print('Error parsing user data: $parseError');
          print('Raw data: ${doc.data()}');
          throw parseError;
        }
      }
      print('User document not found: $userId');
      return null;
    } catch (e) {
      print('Failed to get user: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await usersCollection
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return User.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(dynamic userOrId, [Map<String, dynamic>? data]) async {
    try {
      if (userOrId is User) {
        // If passed a User object, update with its data
        final userData = userOrId.toJson();
        userData['updatedAt'] = FieldValue.serverTimestamp();
        await usersCollection.doc(userOrId.id).update(userData);
      } else if (userOrId is String && data != null) {
        // If passed userId and data map
        data['updatedAt'] = FieldValue.serverTimestamp();
        await usersCollection.doc(userOrId).update(data);
      } else {
        throw Exception('Invalid arguments for updateUser');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await usersCollection.get();
      return querySnapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  /// Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await usersCollection
          .where('role', isEqualTo: role.toString())
          .get();

      return querySnapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  /// Get users by building
  Future<List<User>> getUsersByBuilding(String buildingWing) async {
    try {
      final querySnapshot = await usersCollection
          .where('buildingNumber', isGreaterThanOrEqualTo: buildingWing)
          .where('buildingNumber', isLessThan: '${buildingWing}z')
          .get();

      return querySnapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by building: $e');
    }
  }

  /// Stream of all users (real-time updates)
  Stream<List<User>> usersStream() {
    return usersCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
  }

  /// Stream of a single user
  Stream<User?> userStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // ==================== NOTICE OPERATIONS ====================

  /// Create a notice
  Future<String> createNotice(Map<String, dynamic> notice) async {
    try {
      notice['createdAt'] = FieldValue.serverTimestamp();
      notice['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await noticesCollection.add(notice);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  /// Get all notices
  Future<List<Map<String, dynamic>>> getAllNotices() async {
    try {
      final querySnapshot = await noticesCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notices: $e');
    }
  }

  /// Get notices by type
  Future<List<Map<String, dynamic>>> getNoticesByType(String type) async {
    try {
      final querySnapshot = await noticesCollection
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notices by type: $e');
    }
  }

  /// Update notice
  Future<void> updateNotice(String noticeId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await noticesCollection.doc(noticeId).update(data);
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  /// Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await noticesCollection.doc(noticeId).delete();
    } catch (e) {
      throw Exception('Failed to delete notice: $e');
    }
  }

  /// Stream of notices
  Stream<List<Map<String, dynamic>>> noticesStream() {
    return noticesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ==================== MAINTENANCE OPERATIONS ====================

  /// Create maintenance record
  Future<String> createMaintenanceRecord(Map<String, dynamic> record) async {
    try {
      record['createdAt'] = FieldValue.serverTimestamp();
      record['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await maintenanceCollection.add(record);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create maintenance record: $e');
    }
  }

  /// Get maintenance records for a user
  Future<List<Map<String, dynamic>>> getUserMaintenanceRecords(
      String userId) async {
    try {
      final querySnapshot = await maintenanceCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get maintenance records: $e');
    }
  }

  /// Get all maintenance records
  Future<List<Map<String, dynamic>>> getAllMaintenanceRecords() async {
    try {
      final querySnapshot = await maintenanceCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all maintenance records: $e');
    }
  }

  /// Update maintenance record
  Future<void> updateMaintenanceRecord(
      String recordId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await maintenanceCollection.doc(recordId).update(data);
    } catch (e) {
      throw Exception('Failed to update maintenance record: $e');
    }
  }

  /// Stream of maintenance records for a user
  Stream<List<Map<String, dynamic>>> userMaintenanceStream(String userId) {
    return maintenanceCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Create payment record
  Future<String> createPayment(Map<String, dynamic> payment) async {
    try {
      payment['createdAt'] = FieldValue.serverTimestamp();
      payment['status'] = payment['status'] ?? 'pending';
      final docRef = await paymentsCollection.add(payment);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Get payments for a user
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final querySnapshot = await paymentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      await paymentsCollection.doc(paymentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // ==================== COMPLAINT OPERATIONS ====================

  /// Create complaint
  Future<String> createComplaint(Map<String, dynamic> complaint) async {
    try {
      complaint['createdAt'] = FieldValue.serverTimestamp();
      complaint['updatedAt'] = FieldValue.serverTimestamp();
      complaint['status'] = complaint['status'] ?? 'open';
      final docRef = await complaintsCollection.add(complaint);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  /// Get complaints for a user
  Future<List<Map<String, dynamic>>> getUserComplaints(String userId) async {
    try {
      final querySnapshot = await complaintsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get complaints: $e');
    }
  }

  /// Get all complaints (admin)
  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    try {
      final querySnapshot = await complaintsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all complaints: $e');
    }
  }

  /// Update complaint status
  Future<void> updateComplaintStatus(
      String complaintId, String status, String? resolution) async {
    try {
      final Map<String, dynamic> data = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (resolution != null) {
        data['resolution'] = resolution;
        data['resolvedAt'] = FieldValue.serverTimestamp();
      }
      await complaintsCollection.doc(complaintId).update(data);
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  /// Stream of complaints
  Stream<List<Map<String, dynamic>>> complaintsStream() {
    return complaintsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ==================== EVENTS OPERATIONS ====================

  /// Create event
  Future<String> createEvent(Map<String, dynamic> event) async {
    try {
      event['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await eventsCollection.add(event);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Get upcoming events
  Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await eventsCollection
          .where('eventDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .orderBy('eventDate')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  /// Stream of events
  Stream<List<Map<String, dynamic>>> eventsStream() {
    return eventsCollection
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ==================== VISITOR OPERATIONS ====================

  /// Log visitor entry
  Future<String> logVisitorEntry(Map<String, dynamic> visitor) async {
    try {
      visitor['entryTime'] = FieldValue.serverTimestamp();
      visitor['status'] = 'in';
      final docRef = await visitorsCollection.add(visitor);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to log visitor entry: $e');
    }
  }

  /// Log visitor exit
  Future<void> logVisitorExit(String visitorId) async {
    try {
      await visitorsCollection.doc(visitorId).update({
        'exitTime': FieldValue.serverTimestamp(),
        'status': 'out',
      });
    } catch (e) {
      throw Exception('Failed to log visitor exit: $e');
    }
  }

  /// Get visitors for a flat
  Future<List<Map<String, dynamic>>> getVisitorsForFlat(
      String buildingNumber) async {
    try {
      final querySnapshot = await visitorsCollection
          .where('visitingFlat', isEqualTo: buildingNumber)
          .orderBy('entryTime', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get visitors: $e');
    }
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Get society settings
  Future<Map<String, dynamic>?> getSocietySettings() async {
    try {
      final doc = await settingsCollection.doc('society').get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  /// Update society settings
  Future<void> updateSocietySettings(Map<String, dynamic> settings) async {
    try {
      settings['updatedAt'] = FieldValue.serverTimestamp();
      await settingsCollection.doc('society').set(settings, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Batch write multiple documents
  Future<void> batchWrite(
      List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final String type = operation['type'];
        final String collection = operation['collection'];
        final String? docId = operation['docId'];
        final Map<String, dynamic>? data = operation['data'];

        final collectionRef = _firestore.collection(collection);

        switch (type) {
          case 'set':
            if (docId != null && data != null) {
              batch.set(collectionRef.doc(docId), data);
            }
            break;
          case 'update':
            if (docId != null && data != null) {
              batch.update(collectionRef.doc(docId), data);
            }
            break;
          case 'delete':
            if (docId != null) {
              batch.delete(collectionRef.doc(docId));
            }
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Batch write failed: $e');
    }
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) transactionHandler) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  /// Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Generate a unique document ID
  String generateDocId(String collection) {
    return _firestore.collection(collection).doc().id;
  }

  // ==================== SEED DATA ====================

  /// Seed initial notices if collection is empty
  Future<void> seedInitialNotices() async {
    try {
      print('Checking if notices exist...');
      final snapshot = await noticesCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Notices already exist, skipping seed');
        return;
      }

      print('Seeding initial notices...');

      final notices = [
        {
          'title': 'Welcome to MySociety!',
          'message': 'Thank you for joining our society management platform. Stay updated with all important announcements here.',
          'priority': 'high',
          'type': 'general',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Monthly Maintenance Due',
          'message': 'Reminder: Monthly maintenance of ₹5,000 is due by the 10th of every month. Please ensure timely payment to avoid late fees.',
          'priority': 'high',
          'type': 'maintenance',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Diwali Celebration 2025',
          'message': 'Join us for the annual Diwali celebration on 1st November at the society clubhouse. Snacks and entertainment arranged for all residents!',
          'priority': 'medium',
          'type': 'event',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Water Tank Cleaning',
          'message': 'Water supply will be interrupted on Sunday from 9 AM to 1 PM due to tank cleaning. Please store water accordingly.',
          'priority': 'high',
          'type': 'maintenance',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'New Parking Rules',
          'message': 'Please park only in designated spots. Vehicles parked in visitor areas overnight will be towed. Contact security for guest parking passes.',
          'priority': 'medium',
          'type': 'rules',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final notice in notices) {
        await noticesCollection.add(notice);
      }

      print('Successfully seeded ${notices.length} notices');
    } catch (e) {
      print('Error seeding notices: $e');
    }
  }

  /// Seed all initial data
  Future<void> seedInitialData() async {
    await seedInitialNotices();
  }
}
