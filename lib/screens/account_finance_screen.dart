import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AccountFinanceScreen extends StatelessWidget {
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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Account & Finance',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Finance Summary Card
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Finance Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildFinanceRow('Total Income', 'Rs.2,50,000'),
                              _buildFinanceRow('Total Expense', 'Rs.1,80,000'),
                              _buildFinanceRow('Balance', 'Rs.70,000'),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Monthly Maintenance Card
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Maintenance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildFinanceRow('Collected', 'Rs.1,20,000'),
                              _buildFinanceRow('Pending Dues', 'Rs.30,000'),
                              _buildFinanceRow('Flats Pending', '12'),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Expenses Card
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildFinanceRow('1. Security Salary', 'Rs.50,000'),
                              _buildFinanceRow('2. Electricity Bill', 'Rs.20,000'),
                              _buildFinanceRow('3. Water Bill', 'Rs.10,000'),
                              _buildFinanceRow('4. Cleaning Services', 'Rs.15,000'),
                              _buildFinanceRow('5. Repairs', 'Rs.25,000'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}