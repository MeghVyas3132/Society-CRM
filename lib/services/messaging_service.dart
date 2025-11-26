// services/messaging_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'database_service.dart';

/// Firebase Cloud Messaging Service
/// Handles push notifications for the app
class MessagingService {
  // Singleton pattern
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService._();
    return _instance!;
  }

  MessagingService._();

  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Database service
  final DatabaseService _databaseService = DatabaseService.instance;

  // Stream controller for notifications
  final StreamController<NotificationMessage> _notificationStreamController =
      StreamController<NotificationMessage>.broadcast();

  // FCM Token
  String? _fcmToken;

  // ==================== GETTERS ====================

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Stream of incoming notifications
  Stream<NotificationMessage> get notificationStream =>
      _notificationStreamController.stream;

  // ==================== INITIALIZATION ====================

  /// Initialize Firebase Messaging
  /// Call this in main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    try {
      // On web, don't auto-request permission (requires user gesture)
      // Permission will be requested when user explicitly enables notifications
      if (!kIsWeb) {
        await requestPermission();
      }

      // Get FCM token (only works after permission is granted)
      try {
        _fcmToken = await _messaging.getToken();
        if (kDebugMode) {
          print('FCM Token: $_fcmToken');
        }
      } catch (e) {
        // Token might not be available on web without permission
        if (kDebugMode) {
          print('FCM Token not available yet: $e');
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _onTokenRefresh(newToken);
      });

      // Configure message handlers
      _configureMessageHandlers();

    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize messaging: $e');
      }
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final bool isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (kDebugMode) {
        print('Notification permission: ${settings.authorizationStatus}');
      }

      return isAuthorized;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request permission: $e');
      }
      return false;
    }
  }

  /// Configure message handlers for foreground, background, and terminated states
  void _configureMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened from a notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification (terminated state)
    _checkInitialMessage();
  }

  /// Check if app was launched from a notification
  Future<void> _checkInitialMessage() async {
    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // ==================== MESSAGE HANDLERS ====================

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.notification?.title}');
    }

    final notification = NotificationMessage.fromRemoteMessage(message);
    _notificationStreamController.add(notification);

    // You can show a local notification here using flutter_local_notifications
    // For now, we just emit to the stream
  }

  /// Handle notification tap (when app is opened from notification)
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.notification?.title}');
    }

    final notification = NotificationMessage.fromRemoteMessage(message);
    notification.isTapped = true;
    _notificationStreamController.add(notification);

    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? id = data['id'];

    // You can use GetX or Navigator to navigate
    // Example navigation handling:
    switch (type) {
      case 'notice':
        // Navigate to notice detail screen
        // Get.toNamed('/notice/$id');
        break;
      case 'maintenance':
        // Navigate to maintenance screen
        // Get.toNamed('/maintenance');
        break;
      case 'payment':
        // Navigate to payments screen
        // Get.toNamed('/payments');
        break;
      case 'complaint':
        // Navigate to complaint detail
        // Get.toNamed('/complaint/$id');
        break;
      case 'event':
        // Navigate to events screen
        // Get.toNamed('/events');
        break;
      default:
        // Navigate to dashboard
        // Get.toNamed('/dashboard');
        break;
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String newToken) {
    if (kDebugMode) {
      print('FCM Token refreshed: $newToken');
    }
    // Update token in Firestore for the current user
    // This will be called from FirebaseAuthService after user logs in
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Save FCM token for a user
  Future<void> saveUserToken(String userId) async {
    if (_fcmToken == null) {
      _fcmToken = await _messaging.getToken();
    }

    if (_fcmToken != null) {
      await _databaseService.updateUser(userId, {
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Remove FCM token for a user (on logout)
  Future<void> removeUserToken(String userId) async {
    await _databaseService.updateUser(userId, {
      'fcmToken': null,
      'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get current FCM token (refresh if needed)
  Future<String?> getToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  /// Delete current FCM token
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
  }

  // ==================== TOPIC SUBSCRIPTION ====================

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to topic $topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unsubscribe from topic $topic: $e');
      }
    }
  }

  /// Subscribe user to default topics based on their building
  Future<void> subscribeToUserTopics(String buildingNumber) async {
    // Subscribe to all society-wide notifications
    await subscribeToTopic('all_residents');

    // Subscribe to building-specific notifications
    final String buildingWing = buildingNumber.isNotEmpty
        ? buildingNumber.substring(0, 1).toUpperCase()
        : '';
    if (buildingWing.isNotEmpty) {
      await subscribeToTopic('building_$buildingWing');
    }

    // Subscribe to general notices
    await subscribeToTopic('notices');

    // Subscribe to maintenance updates
    await subscribeToTopic('maintenance');

    // Subscribe to events
    await subscribeToTopic('events');
  }

  /// Unsubscribe user from all topics (on logout)
  Future<void> unsubscribeFromAllTopics(String buildingNumber) async {
    await unsubscribeFromTopic('all_residents');

    final String buildingWing = buildingNumber.isNotEmpty
        ? buildingNumber.substring(0, 1).toUpperCase()
        : '';
    if (buildingWing.isNotEmpty) {
      await unsubscribeFromTopic('building_$buildingWing');
    }

    await unsubscribeFromTopic('notices');
    await unsubscribeFromTopic('maintenance');
    await unsubscribeFromTopic('events');
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Open app notification settings
  Future<void> openNotificationSettings() async {
    await _messaging.requestPermission();
  }

  // ==================== SEND NOTIFICATIONS (via Cloud Functions) ====================

  /// These methods prepare notification data to be sent via Firebase Cloud Functions
  /// You'll need to set up Cloud Functions to actually send the notifications

  /// Create notification data for a new notice
  Map<String, dynamic> createNoticeNotificationData({
    required String noticeId,
    required String title,
    required String body,
    String? topic,
  }) {
    return {
      'type': 'notice',
      'noticeId': noticeId,
      'notification': {
        'title': title,
        'body': body,
      },
      'topic': topic ?? 'notices',
      'data': {
        'type': 'notice',
        'id': noticeId,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
  }

  /// Create notification data for maintenance reminder
  Map<String, dynamic> createMaintenanceReminderData({
    required String userId,
    required String amount,
    required String dueDate,
  }) {
    return {
      'type': 'maintenance',
      'userId': userId,
      'notification': {
        'title': 'Maintenance Due Reminder',
        'body': 'Your maintenance of ₹$amount is due on $dueDate',
      },
      'data': {
        'type': 'maintenance',
        'amount': amount,
        'dueDate': dueDate,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
  }

  /// Create notification data for complaint update
  Map<String, dynamic> createComplaintUpdateData({
    required String userId,
    required String complaintId,
    required String status,
    String? resolution,
  }) {
    return {
      'type': 'complaint',
      'userId': userId,
      'notification': {
        'title': 'Complaint Update',
        'body': 'Your complaint status has been updated to: $status',
      },
      'data': {
        'type': 'complaint',
        'id': complaintId,
        'status': status,
        'resolution': resolution ?? '',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
  }

  /// Create notification data for new event
  Map<String, dynamic> createEventNotificationData({
    required String eventId,
    required String eventName,
    required String eventDate,
    String? topic,
  }) {
    return {
      'type': 'event',
      'eventId': eventId,
      'notification': {
        'title': 'New Event: $eventName',
        'body': 'A new event has been scheduled for $eventDate',
      },
      'topic': topic ?? 'events',
      'data': {
        'type': 'event',
        'id': eventId,
        'eventName': eventName,
        'eventDate': eventDate,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
  }

  /// Create notification data for visitor arrival
  Map<String, dynamic> createVisitorNotificationData({
    required String userId,
    required String visitorName,
    required String purpose,
  }) {
    return {
      'type': 'visitor',
      'userId': userId,
      'notification': {
        'title': 'Visitor at Gate',
        'body': '$visitorName is here. Purpose: $purpose',
      },
      'data': {
        'type': 'visitor',
        'visitorName': visitorName,
        'purpose': purpose,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
  }

  // ==================== CLEANUP ====================

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}

/// Notification message model
class NotificationMessage {
  final String? id;
  final String? title;
  final String? body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  bool isTapped;
  bool isRead;

  NotificationMessage({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    required this.data,
    required this.receivedAt,
    this.isTapped = false,
    this.isRead = false,
  });

  /// Create from Firebase RemoteMessage
  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      id: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      receivedAt: message.sentTime ?? DateTime.now(),
    );
  }

  /// Get notification type from data
  String? get type => data['type'] as String?;

  /// Get associated item ID from data
  String? get itemId => data['id'] as String?;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'isTapped': isTapped,
      'isRead': isRead,
    };
  }

  /// Create from JSON
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isTapped: json['isTapped'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationMessage(title: $title, body: $body, type: $type)';
  }
}

/// Background message handler
/// Must be a top-level function (not a class method)
/// Add this to your main.dart file:
/// 
/// ```dart
/// @pragma('vm:entry-point')
/// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///   print('Handling background message: ${message.messageId}');
/// }
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///   
///   // Set background message handler
///   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
///   
///   runApp(MySocietyApp());
/// }
/// ```
