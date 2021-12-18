import 'package:admin_college_project/screens/login_screen.dart';
import 'package:admin_college_project/screens/manageCategories.dart';
import 'package:admin_college_project/screens/manageDept.dart';
import 'package:admin_college_project/screens/manageDiv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/createMessage.dart';
import 'screens/manageBatches.dart';
class drawer extends StatefulWidget {
  const drawer({Key? key}) : super(key: key);

  @override
  _drawerState createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    Future<void> logout(BuildContext context) async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Center(child: Text('College Project')),
          ),
          ListTile(
            title: const Text('Create Message'),
            onTap: () {
              Navigator.push(
                  (context),
                  MaterialPageRoute(builder: (context) => CreateMessage()));
            },
          ),
          ListTile(
            title: const Text('Modify Batches'),
            onTap: () {
              Navigator.push(
                  (context),
                  MaterialPageRoute(builder: (context) => ManageBatch()));
            },
          ),
          ListTile(
            title: const Text('Modify Department'),
            onTap: () {
              Navigator.push(
                  (context),
                  MaterialPageRoute(builder: (context) => ManageDept()));
            },
          ),
          ListTile(
            title: const Text('Modify Division'),
            onTap: () {
              Navigator.push(
                  (context),
                  MaterialPageRoute(builder: (context) => ManageDiv()));
            },
          ),

          ListTile(
            title: const Text('Modify Category'),
            onTap: () {
              Navigator.push(
                  (context),
                  MaterialPageRoute(builder: (context) => ManageCategory()));
            },
          ),

          ListTile(
            title: const Text('Logout'),
            onTap: () {
              logout(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
