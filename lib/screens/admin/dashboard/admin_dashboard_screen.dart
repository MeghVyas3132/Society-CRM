
import 'package:flutter/material.dart';
import 'package:mysociety/screens/admin/finance/admin_finance_screen.dart';
import 'package:mysociety/screens/admin/maintenance/admin_maintenance_screen.dart';
import 'package:mysociety/screens/admin/members/admin_members_screen.dart'
    show AdminMembersScreen;
import 'package:mysociety/screens/admin/notices/admin_notices_screen.dart'
    show AdminNoticesScreen;
import '../../../utils/app_colors.dart';
import '../../../services/firebase_auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String userName;
  final String buildingName;

  const AdminDashboardScreen({
    Key? key,
    required this.userName,
    required this.buildingName,
  }) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuthService.instance.signOut();
      // AuthWrapper will handle navigation back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 35, color: AppColors.primaryBlue),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName, // ✅ Show user’s name
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Building: $buildingName", // ✅ Show building name
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        // Text(
                        //   "Flat No: $flatNo", // ✅ Show flat number
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.white.withOpacity(0.9),
                        //   ),
                        // ),
                      ],
                    ),
                    ),
                    // RED Logout Button
                    GestureDetector(
                      onTap: () => _handleLogout(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Dashboard Body
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome, ${userName.split(' ').first}!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          children: [
                            _buildDashboardCard(
                              context,
                              'Notice\n&\nCommunication',
                              Icons.message_rounded,
                              Color(0xFF2196F3),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminNoticesScreen(),
                                ),
                              ),
                            ),
                            _buildDashboardCard(
                              context,
                              'Maintenance\n&\nBilling',
                              Icons.receipt_long,
                              Color(0xFF4CAF50),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminMaintenanceScreen(),
                                ),
                              ),
                            ),
                            _buildDashboardCard(
                              context,
                              'Accounting\nof\nSociety',
                              Icons.account_balance,
                              Color(0xFFFF9800),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminFinanceScreen(),
                                ),
                              ),
                            ),
                            _buildDashboardCard(
                              context,
                              'Member\n&\nResident',
                              Icons.people,
                              Color(0xFF9C27B0),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminMembersScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Reusable card widget
  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.white, size: 30),
            ),
            SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
