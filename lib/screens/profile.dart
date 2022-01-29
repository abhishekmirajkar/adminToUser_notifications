import 'package:admin_college_project/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool hideMainForm = false;
  bool isLoading = true;
  UserModel loggedInUser = UserModel();

  String? errorMessage;


  final firstNameEditingController = new TextEditingController();
  final secondNameEditingController = new TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  var batchData = [];
  var deptData = [];
  var divData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  
  fetchData(){
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance
        .collection("admins")
        .doc(user?.uid)
        .get()
        .then((value) {
      print(value.data());
      this.loggedInUser = UserModel.fromMap(value.data());
      firstNameEditingController.text = loggedInUser.firstName!;
      secondNameEditingController.text = loggedInUser.secondName!;
      setState(() {
        isLoading = false;
      });
    });



  }
  Widget build(BuildContext context) {
    final firstNameField = TextFormField(
        autofocus: false,
        controller: firstNameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("First Name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          firstNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "First Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ));

    final secondNameField = TextFormField(
        autofocus: false,
        controller: secondNameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Second Name cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          secondNameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Second Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    LoginScreen()), (Route<dynamic> route) => false);
              },
              icon: Icon(Icons.power_settings_new))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xffFB9481),
            )),
        title: const Text("Virtual Notice Board"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Admin Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        SizedBox(height: 65),
                        firstNameField,
                        SizedBox(height: 20),
                        secondNameField,
                        SizedBox(height: 20),
                        subForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget subForm() {
    return Column(
      children: [
        SizedBox(
          height: 40,
        ),
        SizedBox(
          height: 30,
        ),
        Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,
          child: MaterialButton(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                setState(() {
                  //isLoading = true;
                  print(loggedInUser.uid);
                });
                FirebaseFirestore.instance
                    .collection('admins')
                    .doc(loggedInUser.uid)
                    .update({
                  "firstName": firstNameEditingController.text,
                  "secondName": secondNameEditingController.text,
                }).then((value) => fetchData());
              },
              child: Text(
                "Save Changes",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
  }
}
