
import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../utils/app_colors.dart';

class AdminNoticesScreen extends StatefulWidget {
  @override
  _AdminNoticesScreenState createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  bool _isLoading = false;
  String _selectedPriority = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          "Create Notice",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Notice Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter notice title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              SizedBox(height: 20),

              // Message
              Text(
                "Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter notice message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              SizedBox(height: 20),

              // Priority
              Text(
                "Priority",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  underline: Container(),
                  items: [
                    DropdownMenuItem(value: 'low', child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Low'),
                    )),
                    DropdownMenuItem(value: 'medium', child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Medium'),
                    )),
                    DropdownMenuItem(value: 'high', child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('High'),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value ?? 'medium';
                    });
                  },
                ),
              ),

              SizedBox(height: 40),

              // Send Button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleSendNotice,
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Text(
                              'Send Notice to All Residents',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

              SizedBox(height: 16),

              // Clear Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleClear,
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Future<void> _handleSendNotice() async {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter notice title', isError: true);
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showMessage('Please enter notice message', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notice = {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'priority': _selectedPriority,
        'type': 'general',
        'createdAt': DateTime.now().toIso8601String(),
      };

      print('Creating notice: $notice');
      final noticeId = await DatabaseService.instance.createNotice(notice);
      print('Notice created with ID: $noticeId');

      _showMessage('Notice sent successfully to all residents!');
      _handleClear();

      // Go back after 1 second
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error sending notice: $e');
      _showMessage('Failed to send notice: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleClear() {
    _titleController.clear();
    _messageController.clear();
    _selectedPriority = 'medium';
    setState(() {});
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _priorityController.dispose();
    super.dispose();
  }
}
