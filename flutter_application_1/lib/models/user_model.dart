
class User {
  final String id;
  final String username;
  final String email;
  final String buildingNumber;
  final String mobileNumber;
  final UserRole role;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final UserStatus status;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.buildingNumber,
    required this.mobileNumber,
    required this.role,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.isActive = true,
    this.status = UserStatus.active,
    this.metadata,
  });

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;
  
  /// Check if user is regular member
  bool get isUser => role == UserRole.user;
  
  /// Check if user is super admin
  bool get isSuperAdmin => role == UserRole.superAdmin;
  
  /// Check if user is manager
  bool get isManager => role == UserRole.manager;

  /// Get user's initials for profile picture
  String get initials {
    List<String> names = username.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].length >= 2) {
      return names[0].substring(0, 2).toUpperCase();
    }
    return 'U';
  }

  /// Get user role as readable string
  String get roleString {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'Resident';
      case UserRole.guest:
        return 'Guest';
    }
  }

  /// Get user status as readable string
  String get statusString {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending Approval';
      case UserStatus.blocked:
        return 'Blocked';
    }
  }

  /// Get formatted mobile number
  String get formattedMobileNumber {
    if (mobileNumber.isEmpty) return '';
    
    // Remove all non-digits
    String cleaned = mobileNumber.replaceAll(RegExp(r'\D'), '');
    
    // Format Indian mobile number
    if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    } else if (cleaned.length == 13 && cleaned.startsWith('91')) {
      String number = cleaned.substring(2);
      return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
    }
    
    return mobileNumber;
  }

  /// Get building floor from building number
  String get buildingFloor {
    if (buildingNumber.length >= 3) {
      String floor = buildingNumber.substring(buildingNumber.length - 3, buildingNumber.length - 2);
      return floor;
    }
    return '';
  }

  /// Get building wing from building number
  String get buildingWing {
    if (buildingNumber.isNotEmpty) {
      return buildingNumber.substring(0, 1).toUpperCase();
    }
    return '';
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return username.isNotEmpty &&
           email.isNotEmpty &&
           buildingNumber.isNotEmpty &&
           mobileNumber.isNotEmpty;
  }

  /// Get user's full address
  String get fullAddress {
    return 'Flat $buildingNumber, MySociety Complex';
  }

  /// Get user age based on metadata
  int? get age {
    if (metadata != null && metadata!.containsKey('dateOfBirth')) {
      try {
        DateTime dob = DateTime.parse(metadata!['dateOfBirth']);
        DateTime now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        return age;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get user's emergency contact
  String? get emergencyContact {
    return metadata?['emergencyContact'] as String?;
  }

  /// Get user's occupation
  String? get occupation {
    return metadata?['occupation'] as String?;
  }

  /// Get number of family members
  int get familyMembersCount {
    return (metadata?['familyMembers'] as List<dynamic>?)?.length ?? 1;
  }

  /// Check if user has vehicle
  bool get hasVehicle {
    return metadata?['hasVehicle'] == true;
  }

  /// Get vehicle details
  List<Vehicle> get vehicles {
    if (metadata != null && metadata!.containsKey('vehicles')) {
      List<dynamic> vehicleData = metadata!['vehicles'] as List<dynamic>;
      return vehicleData.map((v) => Vehicle.fromJson(v as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Get user permissions based on role
  List<String> get permissions {
    switch (role) {
      case UserRole.superAdmin:
        return [
          'manage_all_users',
          'system_settings',
          'backup_restore',
          'view_all_data',
          'delete_any_data',
          'manage_admins',
          ...UserPermissions.adminPermissions,
        ];
      case UserRole.admin:
        return UserPermissions.adminPermissions;
      case UserRole.manager:
        return [
          'manage_maintenance',
          'view_reports',
          'manage_notices',
          'view_finances',
          ...UserPermissions.userPermissions,
        ];
      case UserRole.user:
        return UserPermissions.userPermissions;
      case UserRole.guest:
        return UserPermissions.guestPermissions;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Create copy of user with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? buildingNumber,
    String? mobileNumber,
    UserRole? role,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    UserStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'buildingNumber': buildingNumber,
      'mobileNumber': mobileNumber,
      'role': role.toString(),
      'profilePicture': profilePicture,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'status': status.toString(),
      'metadata': metadata,
    };
  }

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      buildingNumber: json['buildingNumber'] as String,
      mobileNumber: json['mobileNumber'] as String? ?? '',
      role: _parseUserRole(json['role'] as String?),
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] as bool? ?? true,
      status: _parseUserStatus(json['status'] as String?),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Parse user role from string
  static UserRole _parseUserRole(String? roleString) {
    switch (roleString) {
      case 'UserRole.admin':
        return UserRole.admin;
      case 'UserRole.superAdmin':
        return UserRole.superAdmin;
      case 'UserRole.manager':
        return UserRole.manager;
      case 'UserRole.guest':
        return UserRole.guest;
      case 'UserRole.user':
      default:
        return UserRole.user;
    }
  }

  /// Parse user status from string
  static UserStatus _parseUserStatus(String? statusString) {
    switch (statusString) {
      case 'UserStatus.inactive':
        return UserStatus.inactive;
      case 'UserStatus.suspended':
        return UserStatus.suspended;
      case 'UserStatus.pending':
        return UserStatus.pending;
      case 'UserStatus.blocked':
        return UserStatus.blocked;
      case 'UserStatus.active':
      default:
        return UserStatus.active;
    }
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, role: $roleString, building: $buildingNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
           other.id == id &&
           other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}

/// User roles enum
enum UserRole {
  superAdmin,
  admin,
  manager,
  user,
  guest,
}

/// User status enum
enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
  blocked,
}

/// Vehicle model for user's vehicles
class Vehicle {
  final String id;
  final String type; // car, bike, bicycle
  final String brand;
  final String model;
  final String registrationNumber;
  final String color;
  final bool isPrimary;

  Vehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.registrationNumber,
    required this.color,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'model': model,
      'registrationNumber': registrationNumber,
      'color': color,
      'isPrimary': isPrimary,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      registrationNumber: json['registrationNumber'] as String,
      color: json['color'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

/// Family member model
class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final int age;
  final String? occupation;
  final String? mobileNumber;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
    this.occupation,
    this.mobileNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'age': age,
      'occupation': occupation,
      'mobileNumber': mobileNumber,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      age: json['age'] as int,
      occupation: json['occupation'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
    );
  }
}

/// User permissions class
class UserPermissions {
  static const List<String> superAdminPermissions = [
    'manage_all_users',
    'system_settings',
    'backup_restore',
    'view_all_data',
    'delete_any_data',
    'manage_admins',
    'access_logs',
    'system_maintenance',
  ];

  static const List<String> adminPermissions = [
    'manage_users',
    'create_users',
    'edit_users',
    'deactivate_users',
    'view_user_details',
    'handle_maintenance',
    'approve_maintenance',
    'create_maintenance_requests',
    'send_notices',
    'create_notices',
    'edit_notices',
    'delete_notices',
    'view_reports',
    'export_reports',
    'financial_management',
    'view_finances',
    'manage_finances',
    'approve_registrations',
    'make_admin',
    'remove_admin',
    'manage_society_settings',
  ];

  static const List<String> managerPermissions = [
    'manage_maintenance',
    'view_maintenance_reports',
    'create_maintenance_requests',
    'approve_maintenance_requests',
    'manage_notices',
    'create_notices',
    'view_reports',
    'view_finances',
    'view_user_list',
    'contact_users',
  ];

  static const List<String> userPermissions = [
    'view_profile',
    'update_profile',
    'change_password',
    'pay_maintenance',
    'view_maintenance_history',
    'create_maintenance_request',
    'view_notices',
    'view_members',
    'contact_members',
    'view_personal_finances',
    'view_society_info',
    'update_family_details',
    'manage_vehicles',
  ];

  static const List<String> guestPermissions = [
    'view_public_notices',
    'contact_admin',
    'view_society_info',
  ];

  /// Check if a role has a specific permission
  static bool roleHasPermission(UserRole role, String permission) {
    switch (role) {
      case UserRole.superAdmin:
        return superAdminPermissions.contains(permission) || 
               adminPermissions.contains(permission) ||
               managerPermissions.contains(permission) ||
               userPermissions.contains(permission);
      case UserRole.admin:
        return adminPermissions.contains(permission) ||
               managerPermissions.contains(permission) ||
               userPermissions.contains(permission);
      case UserRole.manager:
        return managerPermissions.contains(permission) ||
               userPermissions.contains(permission);
      case UserRole.user:
        return userPermissions.contains(permission);
      case UserRole.guest:
        return guestPermissions.contains(permission);
    }
  }
}

/// User validation utility
class UserValidator {
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate mobile number
  static bool isValidMobileNumber(String mobile) {
    String cleaned = mobile.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 10 || (cleaned.length == 13 && cleaned.startsWith('91'));
  }

  /// Validate building number format
  static bool isValidBuildingNumber(String building) {
    return RegExp(r'^[A-Z]-\d{3}$', caseSensitive: false).hasMatch(building);
  }

  /// Validate username
  static bool isValidUsername(String username) {
    return username.trim().length >= 2 && username.trim().length <= 50;
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Get password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score > 4 ? 4 : score;
  }
}

/// User helper utilities
class UserUtils {
  /// Generate user ID
  static String generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Format building number
  static String formatBuildingNumber(String building) {
    return building.toUpperCase().trim();
  }

  /// Get role color
  static String getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return '#E91E63'; // Pink
      case UserRole.admin:
        return '#FF6F00'; // Orange
      case UserRole.manager:
        return '#9C27B0'; // Purple
      case UserRole.user:
        return '#1976D2'; // Blue
      case UserRole.guest:
        return '#757575'; // Grey
    }
  }

  /// Get status color
  static String getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return '#4CAF50'; // Green
      case UserStatus.inactive:
        return '#757575'; // Grey
      case UserStatus.suspended:
        return '#FF9800'; // Orange
      case UserStatus.pending:
        return '#2196F3'; // Blue
      case UserStatus.blocked:
        return '#F44336'; // Red
    }
  }
}