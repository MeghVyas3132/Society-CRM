// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'screens/forgot_password_screen.dart';
// import 'screens/splash_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/profile_router_screen.dart';
// import 'screens/notice_communication_screen.dart';
// import 'screens/maintenance_billing_screen.dart';
// import 'screens/account_finance_screen.dart';
// import 'screens/member_resident_screen.dart';
// import 'screens/auth_wrapper.dart';

// Future<void> main() async {
//   var widgetsFlutterBinding;
//   widgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp();
//   runApp(MySocietyApp());
// }

// class MySocietyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MySociety',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       initialRoute: '/', // start at splash
//       routes: {
//         '/': (context) => SplashScreen(),
//         '/auth': (context) => AuthWrapper(), // ✅ After splash → AuthWrapper
//         '/login': (context) => LoginScreen(),
//         '/register': (context) => RegisterScreen(),
//         '/forgot-password': (context) => ForgotPasswordScreen(),
//         '/dashboard': (context) => DashboardScreen(
//               userName: '',
//             ),
//         '/profile': (context) => ProfileRouterScreen(),
//         '/notice': (context) => NoticeCommunicationScreen(),
//         '/maintenance': (context) => MaintenanceBillingScreen(),
//         '/finance': (context) => AccountFinanceScreen(),
//         '/members': (context) => MemberResidentScreen(),
//       },
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';  // <-- Import the generated file
import 'services/firebase_auth_service.dart';
import 'services/messaging_service.dart';
import 'services/database_service.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_router_screen.dart';
import 'screens/notice_communication_screen.dart';
import 'screens/maintenance_billing_screen.dart';
import 'screens/account_finance_screen.dart';
import 'screens/member_resident_screen.dart';
import 'screens/auth_wrapper.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable reCAPTCHA enforcement for web development
  await FirebaseAuthService.instance.firebaseAuth.setSettings(
    appVerificationDisabledForTesting: true,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Auth Service
  FirebaseAuthService.instance.initialize();

  // Initialize Messaging Service
  await MessagingService.instance.initialize();

  // Seed initial data (notices, etc.) if empty
  await DatabaseService.instance.seedInitialData();

  runApp(MySocietyApp());
}

class MySocietyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySociety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // start at AuthWrapper
      routes: {
        '/': (context) => AuthWrapper(), // AuthWrapper handles splash + auth
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/dashboard': (context) => DashboardScreen(
              userName: '',
            ),
        '/profile': (context) => ProfileRouterScreen(),
        '/notice': (context) => NoticeCommunicationScreen(),
        '/maintenance': (context) => MaintenanceBillingScreen(),
        '/finance': (context) => AccountFinanceScreen(),
        '/members': (context) => MemberResidentScreen(),
      },
    );
  }
}
