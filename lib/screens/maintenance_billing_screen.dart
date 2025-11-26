import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../services/firebase_auth_service.dart';

class MaintenanceBillingScreen extends StatefulWidget {
  @override
  _MaintenanceBillingScreenState createState() =>
      _MaintenanceBillingScreenState();
}

class _MaintenanceBillingScreenState extends State<MaintenanceBillingScreen> {
  bool isMaintenanceSelected = true;
  bool _isSubmitting = false;

  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _rupeesController = TextEditingController();
  final _upiIdController = TextEditingController();

  final _billDetailsController = TextEditingController();
  final _billRupeesController = TextEditingController();
  final _billUpiIdController = TextEditingController();

  // ✅ Radio Button State (only UPI remains)
  String _maintenancePaymentType = "UPI";
  String _billingPaymentType = "UPI";

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
              // Custom AppBar
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Maintenance & Billing',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tabs
                      Row(
                        children: [
                          _buildTabButton("Maintenance", true),
                          SizedBox(width: 12),
                          _buildTabButton("Billing", false),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Scrollable Form
                      Expanded(
                        child: SingleChildScrollView(
                          child: isMaintenanceSelected
                              ? _buildMaintenanceContent()
                              : _buildBillingContent(),
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

  Widget _buildTabButton(String text, bool maintenance) {
    bool selected = isMaintenanceSelected == maintenance;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isMaintenanceSelected = maintenance;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.darkGrey,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Maintenance :", style: _titleStyle()),
        SizedBox(height: 12),
        _buildFormField("Month :", _monthController),
        SizedBox(height: 12),
        _buildFormField("Year :", _yearController),
        SizedBox(height: 12),
        _buildFormField("Rupees :", _rupeesController),
        SizedBox(height: 12),
        Text("Payment Type:", style: TextStyle(fontSize: 13)),
        _buildPaymentType(_upiIdController, _maintenancePaymentType, (value) {
          setState(() {
            _maintenancePaymentType = value!;
          });
        }),
        SizedBox(height: 20),
        _buildSubmitButton(() => _submitMaintenanceForm()),
      ],
    );
  }

  Widget _buildBillingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Billing :", style: _titleStyle()),
        SizedBox(height: 12),
        _buildFormField("Bill Details :", _billDetailsController),
        SizedBox(height: 12),
        _buildFormField("Rupees :", _billRupeesController),
        SizedBox(height: 12),
        Text("Payment Type:", style: TextStyle(fontSize: 13)),
        _buildPaymentType(_billUpiIdController, _billingPaymentType, (value) {
          setState(() {
            _billingPaymentType = value!;
          });
        }),
        SizedBox(height: 20),
        _buildSubmitButton(() => _submitBillingForm()),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  /// ✅ Only UPI Option
  Widget _buildPaymentType(TextEditingController controller,
      String selectedValue, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Radio<String>(
          value: "UPI",
          groupValue: selectedValue,
          onChanged: onChanged,
          activeColor: AppColors.primaryBlue,
        ),
        Text("UPI ID", style: TextStyle(fontSize: 13)),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 17, 150, 216),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text("Add",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
      ),
    );
  }

  TextStyle _titleStyle() => TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue);

  void _submitMaintenanceForm() async {
    if (_monthController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _rupeesController.text.isEmpty) {
      _showSnack("Please fill all maintenance fields", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuthService.instance.currentUser;
      final maintenanceData = {
        'userId': user?.id ?? 'unknown',
        'userName': user?.username ?? 'Unknown User',
        'buildingNumber': user?.buildingNumber ?? 'Unknown',
        'month': _monthController.text.trim(),
        'year': _yearController.text.trim(),
        'amount': double.tryParse(_rupeesController.text.trim()) ?? 0,
        'paymentType': _maintenancePaymentType,
        'upiId': _upiIdController.text.trim(),
        'status': 'pending',
        'createdAt': DateTime.now(),
      };

      await DatabaseService.instance.addDocument('maintenance', maintenanceData);

      _showSnack(
          "Maintenance record added successfully!",
          Colors.green);
      _monthController.clear();
      _yearController.clear();
      _rupeesController.clear();
      _upiIdController.clear();
    } catch (e) {
      _showSnack("Error adding maintenance: $e", Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _submitBillingForm() async {
    if (_billDetailsController.text.isEmpty ||
        _billRupeesController.text.isEmpty) {
      _showSnack("Please fill all billing fields", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuthService.instance.currentUser;
      final paymentData = {
        'userId': user?.id ?? 'unknown',
        'userName': user?.username ?? 'Unknown User',
        'buildingNumber': user?.buildingNumber ?? 'Unknown',
        'description': _billDetailsController.text.trim(),
        'amount': double.tryParse(_billRupeesController.text.trim()) ?? 0,
        'paymentType': _billingPaymentType,
        'upiId': _billUpiIdController.text.trim(),
        'type': 'billing',
        'status': 'pending',
        'createdAt': DateTime.now(),
      };

      await DatabaseService.instance.addDocument('payments', paymentData);

      _showSnack("Billing details added successfully!", Colors.green);
      _billDetailsController.clear();
      _billRupeesController.clear();
      _billUpiIdController.clear();
    } catch (e) {
      _showSnack("Error adding billing: $e", Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    _rupeesController.dispose();
    _upiIdController.dispose();
    _billDetailsController.dispose();
    _billRupeesController.dispose();
    _billUpiIdController.dispose();
    super.dispose();
  }
}
