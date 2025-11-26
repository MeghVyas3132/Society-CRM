
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class AdminFinanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue, // 🔹 Changed here
        title: Text(
          "Account & Finance",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Finance Summary
            _buildBox(
              "Finance Summary",
              Column(
                children: [
                  _rowText("Total Income", "Rs:2,50,000"),
                  _rowText("Total Expense", "Rs:1,80,000"),
                  _rowText("Balance", "Rs:70,000"),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Monthly Maintenance
            _buildBox(
              "Monthly Maintenance",
              Column(
                children: [
                  _rowText("Collected", "Rs:1,20,000"),
                  _rowText("Pending Dues", "Rs:30,000"),
                  _rowText("Flats Pending", "12"),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Expenses
            _buildBox(
              "Expenses",
              Column(
                children: [
                  _rowText("1. Security Salary", "Rs:50,000"),
                  _rowText("2. Electricity Bill", "Rs:20,000"),
                  _rowText("3. Water Bill", "Rs:10,000"),
                  _rowText("4. Cleaning Services", "Rs:15,000"),
                  _rowText("5. Repairs", "Rs:25,000"),
                ],
              ),
            ),
            Spacer(),

            // Add Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                minimumSize: Size(double.infinity, 40), // smaller button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Add",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String title, Widget child) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _rowText(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(fontSize: 12)),
          Text(right, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
