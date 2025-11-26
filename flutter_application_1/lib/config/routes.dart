// TODO Implement this library.
import 'package:flutter/material.dart';

// Import your screens
// import '../screens/admin/dashboard/admin_dashboard_screen.dart';
// import '../screens/admin/profile/admin_profile_screen.dart';
// import '../screens/admin/notices/admin_notices_screen.dart';
// import '../screens/admin/maintenance/admin_maintenance_screen.dart';
// import '../screens/admin/finance/admin_finance_screen.dart';
// import '../screens/admin/members/admin_members_screen.dart';
// import '../screens/admin/auth/login_screen.dart';

class AppRoutes {
  // ✅ Route constants
  static const String login = '/login';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin-dashboard';
  static const String noticeCommunication = '/notice-communication';
  static const String maintenanceBilling = '/maintenance-billing';
  static const String accountFinance = '/account-finance';
  static const String memberResident = '/member-resident';

  // ✅ Map for MaterialApp
  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    profile: (context) => AdminProfileScreen(),
    adminDashboard: (context) => AdminDashboardScreen(),
    noticeCommunication: (context) => NoticeCommunicationScreen(),
    maintenanceBilling: (context) => MaintenanceBillingScreen(),
    accountFinance: (context) => AccountFinanceScreen(),
    memberResident: (context) => MemberResidentScreen(),
  };

  // ignore: non_constant_identifier_names
  static MemberResidentScreen() {}

  // ignore: non_constant_identifier_names
  static AccountFinanceScreen() {}

  // ignore: non_constant_identifier_names
  static MaintenanceBillingScreen() {}

  // ignore: non_constant_identifier_names
  static NoticeCommunicationScreen() {}

  // ignore: non_constant_identifier_names
  static AdminDashboardScreen() {}

  // ignore: non_constant_identifier_names
  static LoginScreen() {}

  // ignore: non_constant_identifier_names
  static AdminProfileScreen() {}
}
