import 'package:flutter/material.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  @override
  _AdminMaintenanceScreenState createState() => _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState extends State<AdminMaintenanceScreen> {
  int _selectedIndex = 0; // 0 = Maintenance, 1 = Billing
  final Color primaryBlue = const Color(0xFF1976D2); // blue gradient color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header (only title + back button)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    'Maintenance & Billing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 24),
              ],
            ),
          ),

          // Buttons AFTER header
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildHeaderButton("Maintenance", 0),
                _buildHeaderButton("Billing", 1),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _selectedIndex == 0
                ? _buildMaintenanceTab()
                : _buildBillingTab(),
          ),
        ],
      ),
    );
  }

  // Tab Button (full width style)
  Widget _buildHeaderButton(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Maintenance Tab
  Widget _buildMaintenanceTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMaintenanceCard("B,903", [
          {
            "month": "March",
            "year": "2025",
            "rupees": "2000",
            "status": "Paid"
          },
          {
            "month": "April",
            "year": "2025",
            "rupees": "1000",
            "status": "Unpaid"
          },
        ]),
        _buildMaintenanceCard("B,1104", [
          {
            "month": "March",
            "year": "2025",
            "rupees": "2000",
            "status": "Paid"
          },
          {
            "month": "April",
            "year": "2025",
            "rupees": "2000",
            "status": "Paid"
          },
        ]),
      ],
    );
  }

  Widget _buildMaintenanceCard(
      String buildingNo, List<Map<String, String>> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Building Number: $buildingNo",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Month"),
              Text("Year"),
              Text("Rupees"),
              Text("Status"),
            ],
          ),
          ...data.map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row["month"]!),
                  Text(row["year"]!),
                  Text(row["rupees"]!),
                  Text(
                    row["status"]!,
                    style: TextStyle(
                      color:
                          row["status"] == "Paid" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // Billing Tab
  Widget _buildBillingTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildBillingCard("B,903", [
          {"bill": "Water Bill", "rupees": "3000", "status": "Paid"},
          {"bill": "Light Bill", "rupees": "6000", "status": "Paid"},
        ]),
        _buildBillingCard("B,1104", [
          {"bill": "Water Bill", "rupees": "3000", "status": "Paid"},
          {"bill": "Light Bill", "rupees": "5000", "status": "Unpaid"},
        ]),
      ],
    );
  }

  Widget _buildBillingCard(String buildingNo, List<Map<String, String>> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Building Number: $buildingNo",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill Details"),
              Text("Rupees"),
              Text("Status"),
            ],
          ),
          ...data.map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row["bill"]!),
                  Text(row["rupees"]!),
                  Text(
                    row["status"]!,
                    style: TextStyle(
                      color:
                          row["status"] == "Paid" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
