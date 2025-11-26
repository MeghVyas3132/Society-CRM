// services/firebase_auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'database_service.dart';

/// Firebase Authentication Service
/// Handles all authentication operations using Firebase Auth
class FirebaseAuthService {
  // Singleton pattern
  static FirebaseAuthService? _instance;
  static FirebaseAuthService get instance {
    _instance ??= FirebaseAuthService._();
    return _instance!;
  }

  FirebaseAuthService._();

  // Firebase Auth instance
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  
  // Database service for user data
  final DatabaseService _databaseService = DatabaseService.instance;

  // Current user cache
  User? _currentUser;

  // Stream controller for custom user model
  final StreamController<User?> _userStreamController =
      StreamController<User?>.broadcast();

  // ==================== GETTERS ====================

  /// Get current Firebase user
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  /// Get Firebase Auth instance (for configuration)
  firebase_auth.FirebaseAuth get firebaseAuth => _firebaseAuth;

  /// Get current app user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Check if user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if user is regular user
  bool get isUser => _currentUser?.isUser ?? false;

  /// Get current user ID
  String get currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  /// Get current user name
  String get currentUserName => _currentUser?.username ?? 'Guest';

  /// Get current user email
  String get currentUserEmail => _currentUser?.email ?? '';

  /// Get current user role string
  String get currentUserRole => _currentUser?.roleString ?? 'Guest';

  /// Stream of auth state changes (Firebase user)
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Stream of app user changes
  Stream<User?> get userChanges => _userStreamController.stream;

  // ==================== AUTHENTICATION METHODS ====================

  /// Initialize auth service and listen to auth changes
  void initialize() {
    print('Initializing FirebaseAuthService...');
    
    // If user is already logged in, load their data immediately
    if (firebaseUser != null) {
      print('User already logged in: ${firebaseUser!.uid}');
      _loadCurrentUser(firebaseUser!.uid);
    }
    
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      print('Auth state changed: ${firebaseUser?.uid}');
      if (firebaseUser != null) {
        // Fetch user data from Firestore
        await _loadCurrentUser(firebaseUser.uid);
      } else {
        _currentUser = null;
        _userStreamController.add(null);
      }
    });
  }

  /// Load current user data from Firestore
  Future<void> _loadCurrentUser(String uid) async {
    try {
      _currentUser = await _databaseService.getUserById(uid);
      print('Loaded user: ${_currentUser?.username}');
      _userStreamController.add(_currentUser);
    } catch (e) {
      print('Error loading user: $e');
      _currentUser = null;
      _userStreamController.add(null);
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    required String buildingNumber,
    String mobileNumber = '',
    UserRole role = UserRole.user,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || username.isEmpty || buildingNumber.isEmpty) {
        return AuthResult.failure('Please fill in all required fields');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters long');
      }

      if (!_isValidBuildingNumber(buildingNumber)) {
        return AuthResult.failure('Please enter a valid building number');
      }

      // Create Firebase user
      final firebase_auth.UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Failed to create account');
      }

      // Update display name
      await credential.user!.updateDisplayName(username);

      // Create user in Firestore with specified role
      final User newUser = User(
        id: credential.user!.uid,
        username: username.trim(),
        email: email.toLowerCase().trim(),
        buildingNumber: buildingNumber.toUpperCase().trim(),
        mobileNumber: mobileNumber,
        role: role, // Use the passed role (admin or user)
        createdAt: DateTime.now(),
        isActive: true,
        status: UserStatus.active,
      );

      print('About to save user to Firestore: ${newUser.toJson()}');
      try {
        await _databaseService.createUser(newUser);
        print('User saved to Firestore successfully!');
      } catch (e) {
        print('ERROR saving to Firestore: $e');
        // Try to delete Firebase Auth user if Firestore save fails
        try {
          await credential.user!.delete();
        } catch (deleteError) {
          print('Could not delete Firebase Auth user: $deleteError');
        }
        return AuthResult.failure('Failed to save user data to database: $e');
      }

      _currentUser = newUser;
      _userStreamController.add(_currentUser);

      return AuthResult.success(newUser, 'Registration successful! Welcome to MySociety.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Please fill in all fields');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      // Sign in with Firebase
      final firebase_auth.UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Login failed');
      }

      // Fetch user data from Firestore
      _currentUser = await _databaseService.getUserById(credential.user!.uid);

      if (_currentUser == null) {
        print('User not found in Firestore for UID: ${credential.user!.uid}');
        print('This usually means Firestore write failed during registration or Firestore rules are blocking reads');
        // User exists in Auth but not in Firestore - create basic profile
        _currentUser = User(
          id: credential.user!.uid,
          username: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? email,
          buildingNumber: '',
          mobileNumber: '',
          role: UserRole.user,
          createdAt: DateTime.now(),
          isActive: true,
          status: UserStatus.active,
        );
        print('Creating new Firestore user record...');
        try {
          await _databaseService.createUser(_currentUser!);
          print('Created new user in Firestore');
        } catch (e) {
          print('Failed to create user in Firestore: $e');
          await signOut();
          return AuthResult.failure('Could not load user profile. Please ensure Firestore is enabled and rules allow authenticated access.');
        }
      } else {
        print('User found in Firestore: ${_currentUser!.username}');
      }

      // Check if account is active
      if (!_currentUser!.isActive) {
        await signOut();
        return AuthResult.failure('Your account has been deactivated. Please contact admin.');
      }

      // Update last login
      await _databaseService.updateUser(credential.user!.uid, {
        'lastLogin': FieldValue.serverTimestamp(),
      });

      _userStreamController.add(_currentUser);

      return AuthResult.success(_currentUser!, 'Login successful!');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _userStreamController.add(null);
    } catch (e) {
      // Even if signOut fails, clear local user
      _currentUser = null;
      _userStreamController.add(null);
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Please enter your email address');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null, 'Password reset email sent. Please check your inbox.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('Please login first');
      }

      if (newPassword.length < 6) {
        return AuthResult.failure('New password must be at least 6 characters long');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult.success(null, 'Password changed successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return AuthResult.failure('Current password is incorrect');
      }
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to change password: ${e.toString()}');
    }
  }

  /// Update user email
  Future<AuthResult> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('Please login first');
      }

      if (!_isValidEmail(newEmail)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await user.verifyBeforeUpdateEmail(newEmail.trim());

      return AuthResult.success(
          null, 'Verification email sent. Please verify your new email address.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to update email: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile(User updatedUser) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('Please login first');
      }

      // Update display name in Firebase Auth
      if (updatedUser.username != user.displayName) {
        await user.updateDisplayName(updatedUser.username);
      }

      // Update in Firestore
      await _databaseService.updateUser(user.uid, {
        'username': updatedUser.username,
        'buildingNumber': updatedUser.buildingNumber,
        'mobileNumber': updatedUser.mobileNumber,
        'metadata': updatedUser.metadata,
      });

      _currentUser = updatedUser;
      _userStreamController.add(_currentUser);

      return AuthResult.success(_currentUser!, 'Profile updated successfully');
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user display name only (simple update)
  Future<void> updateDisplayName({required String displayName}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
      }
    } catch (e) {
      // Silent fail for display name update
    }
  }

  /// Delete user account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('Please login first');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete from Firestore
      await _databaseService.deleteUser(user.uid);

      // Delete from Firebase Auth
      await user.delete();

      _currentUser = null;
      _userStreamController.add(null);

      return AuthResult.success(null, 'Account deleted successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('Please login first');
      }

      if (user.emailVerified) {
        return AuthResult.success(null, 'Email is already verified');
      }

      await user.sendEmailVerification();
      return AuthResult.success(null, 'Verification email sent');
    } catch (e) {
      return AuthResult.failure('Failed to send verification email');
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Reload user data
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
    if (_firebaseAuth.currentUser != null) {
      _currentUser = await _databaseService.getUserById(_firebaseAuth.currentUser!.uid);
      _userStreamController.add(_currentUser);
    }
  }

  // ==================== ADMIN METHODS ====================

  /// Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    if (!isAdmin) {
      throw Exception('Access denied. Admin privileges required.');
    }
    return await _databaseService.getAllUsers();
  }

  /// Update user role (admin only)
  Future<AuthResult> updateUserRole(String userId, UserRole newRole) async {
    if (!isAdmin) {
      return AuthResult.failure('Access denied. Admin privileges required.');
    }

    try {
      await _databaseService.updateUser(userId, {
        'role': newRole.toString(),
      });
      return AuthResult.success(null, 'User role updated successfully');
    } catch (e) {
      return AuthResult.failure('Failed to update user role: ${e.toString()}');
    }
  }

  /// Deactivate user (admin only)
  Future<AuthResult> deactivateUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.failure('Access denied. Admin privileges required.');
    }

    try {
      await _databaseService.updateUser(userId, {
        'isActive': false,
        'status': UserStatus.inactive.toString(),
      });
      return AuthResult.success(null, 'User deactivated successfully');
    } catch (e) {
      return AuthResult.failure('Failed to deactivate user: ${e.toString()}');
    }
  }

  /// Activate user (admin only)
  Future<AuthResult> activateUser(String userId) async {
    if (!isAdmin) {
      return AuthResult.failure('Access denied. Admin privileges required.');
    }

    try {
      await _databaseService.updateUser(userId, {
        'isActive': true,
        'status': UserStatus.active.toString(),
      });
      return AuthResult.success(null, 'User activated successfully');
    } catch (e) {
      return AuthResult.failure('Failed to activate user: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate building number format - more lenient
  bool _isValidBuildingNumber(String buildingNumber) {
    // Accept any non-empty building number
    return buildingNumber.trim().isNotEmpty;
  }

  /// Get user-friendly error message from Firebase error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Invalid password. Please try again';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again';
      case 'requires-recent-login':
        return 'Please log in again to complete this action';
      default:
        return 'An error occurred. Please try again';
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _currentUser?.hasPermission(permission) ?? false;
  }

  /// Dispose resources
  void dispose() {
    _userStreamController.close();
  }
}

/// Authentication result class
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;

  AuthResult._(this.isSuccess, this.message, this.user);

  factory AuthResult.success(User? user, String message) {
    return AuthResult._(true, message, user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(false, message, null);
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message, user: ${user?.username})';
  }
}
