import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
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

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    //  Web Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCdkV9to30WosIzJq_DtB_RNOxj_hEgSBg",
        authDomain: "my-society-management-662e3.firebaseapp.com",
        projectId: "my-society-management-662e3",
        storageBucket: "my-society-management-662e3.firebasestorage.app",
        messagingSenderId: "307392159209",
        appId: "1:307392159209:web:949c06719105517be57f78",
        measurementId: "G-2LLHTTQE89",
      ),
    );
  } else {
    // Android / iOS initialization
    await Firebase.initializeApp();
  }

  runApp(MySocietyApp());
}

class MySocietyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySociety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/auth': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/dashboard': (context) => DashboardScreen(userName: ''),
        '/profile': (context) => ProfileRouterScreen(),
        '/notice': (context) => NoticeCommunicationScreen(),
        '/maintenance': (context) => MaintenanceBillingScreen(),
        '/finance': (context) => AccountFinanceScreen(),
        '/members': (context) => MemberResidentScreen(),
      },
    );
  }
}
