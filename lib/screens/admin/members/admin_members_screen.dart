

import 'package:flutter/material.dart';

class Member {
  final String name;
  final String flat;
  final String building;
  final String phone;

  Member({
    required this.name,
    required this.flat,
    required this.building,
    required this.phone,
  });
}

class AdminMembersScreen extends StatefulWidget {
  @override
  _AdminMembersScreenState createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  List<Member> members = []; // initially empty

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    final buildingController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Member"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Full Name")),
              SizedBox(height: 10),
              TextField(
                  controller: flatController,
                  decoration: InputDecoration(labelText: "Flat No")),
              SizedBox(height: 10),
              TextField(
                  controller: buildingController,
                  decoration: InputDecoration(labelText: "Building No")),
              SizedBox(height: 10),
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Mobile No")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                members.add(Member(
                  name: nameController.text.isEmpty ? "-" : nameController.text,
                  flat: flatController.text.isEmpty ? "-" : flatController.text,
                  building: buildingController.text.isEmpty
                      ? "-"
                      : buildingController.text,
                  phone:
                      phoneController.text.isEmpty ? "-" : phoneController.text,
                ));
              });
              Navigator.pop(context);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Gradient Header with white arrow + white text
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
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white, // ✅ white arrow
                  ),
                ),
                Expanded(
                  child: Text(
                    "Member & Resident",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // ✅ white text
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 24), // keep balance
              ],
            ),
          ),

          // 🔹 Main content
          Expanded(
            child: members.isEmpty
                ? Center(child: Text("No Members Added"))
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text("Member Name: ${member.name}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Flat No: ${member.flat}"),
                              Text("Building No: ${member.building}"),
                              Text("Mobile No: ${member.phone}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                members.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue, // match header theme
        onPressed: _showAddMemberDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
