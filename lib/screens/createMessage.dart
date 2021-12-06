import 'dart:convert';

import 'package:admin_college_project/model/message_model.dart';
import 'package:admin_college_project/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';


class CreateMessage extends StatefulWidget {
  const CreateMessage({Key? key}) : super(key: key);

  @override
  _CreateMessageState createState() => _CreateMessageState();
}

class _CreateMessageState extends State<CreateMessage> {
  final messageEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;


  late String token;
  List<String> userToSendNotiToken =[];


  bool hideMainForm = false;
  bool isLoading = true;

  String? errorMessage;
  String? selectedBatch;
  String? selectedDiv;
  String? selectedDept;

  String? selectedBatchId;
  String? selectedDivId;
  String? selectedDeptId;

  var batchData=[];
  var deptData=[];
  var divData=[];
  UserModel loggedInUser = UserModel();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection("admins")
        .doc(user!.uid)
        .get()
        .then((value) {
          print(value.data());
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });

    FirebaseFirestore.instance
        .collection('batches')
        .get()
        .then((value) async{
      token = "AAAAmGAFB58:APA91bEFNzI2V6tOSiH_G0wNoiAMG1Cjvt_DkM5xHYPY0lh2Vx659FCZ5Avw1QbsXlKvF3_Vn55YEI5Z-oHtqv2NEmAsqiirTdNPGxuFdhHvHh0q_yc4Jb-Kj-28EWQ11BqZnsjVBE7h";
      for (int i = 0; i < value.docs.length; i++) {
        batchData.add(value.docs[i].data());
      }

      FirebaseFirestore.instance
          .collection('divisions')
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          divData.add(value.docs[i].data());
        }
        FirebaseFirestore.instance
            .collection('department')
            .get()
            .then((value) {
          for (int i = 0; i < value.docs.length; i++) {
            deptData.add(value.docs[i].data());
          }
          setState(() {
            isLoading =false;
          });
        });

      });
    });
  }


 callOnFcmApiSendPushNotifications(List <String> userToken){
    userToSendNotiToken.clear();
    FirebaseFirestore.instance
        .collection('users')
        .where("batchId", isEqualTo: selectedBatchId)
        .where("deptId", isEqualTo: selectedDeptId)
        .where("divId", isEqualTo: selectedDivId)
        .get().then((value)async{
      for (int i = 0; i < value.docs.length; i++) {
        userToSendNotiToken.add(value.docs[i].data()['fcmToekn'].toString());
      }
      print(userToSendNotiToken);

      final postUrl = 'fcm.googleapis.com';
      final data = {
        "registration_ids" : userToSendNotiToken,
        "collapse_key" : "type_a",
        "notification" : {
          "title": 'New Message from ${loggedInUser.firstName}',
          "body" : messageEditingController.text,
        }
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization': "key=AAAAmGAFB58:APA91bEFNzI2V6tOSiH_G0wNoiAMG1Cjvt_DkM5xHYPY0lh2Vx659FCZ5Avw1QbsXlKvF3_Vn55YEI5Z-oHtqv2NEmAsqiirTdNPGxuFdhHvHh0q_yc4Jb-Kj-28EWQ11BqZnsjVBE7h"
      };

      final response = await http.post(Uri.https(postUrl,"/fcm/send"),
          body: json.encode(data),
          encoding: Encoding.getByName('utf-8'),
          headers: headers);

      if (response.statusCode == 200) {
        // on success do sth
        print('test ok push CFM');
        return true;
      } else {
        print(response.body);
        print(' CFM error');
        // on failure do sth
        return false;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: drawer(),
      appBar: AppBar(
        title: const Text("Welcome"),
        leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
      ),
      body: Column(
        children: [
          subForm(),
          TextFormField(
              keyboardType: TextInputType.multiline,
              autofocus: false,
              maxLines: 10,
              controller: messageEditingController,
              validator: (value) {
                if (messageEditingController.text.isEmpty) {
                  return "Message Can't Be Empty";
                }
              },
              onSaved: (value) {
                messageEditingController.text = value!;
              },
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.message),
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                hintText: "Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              )),
          submitButton(),
        ],
      ),
    );
  }

  postDetailsToFirestore() async {

    setState(() {
      isLoading =true;
    });

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    MessageModel messageModel = MessageModel();

    // writing all the values
    messageModel.adminId = user!.email!;
    messageModel.batchId = selectedBatchId;
    messageModel.deptId = selectedDeptId;
    messageModel.divId = selectedDivId;
    await firebaseFirestore
        .collection("messages")
        .doc()
        .set({
      'adminId':user.uid,
      'batchId':selectedBatchId,
      'deptId':selectedDeptId,
      'divId':selectedDivId,
      'messageData':messageEditingController.text
    });
    callOnFcmApiSendPushNotifications(["dJ9L_VakN0oGkUi5kAV00G:APA91bGvemgujZdtd3YnSCCgRUiIRkxQQdp6qF-91Oj46FyWKUx3Yps8q4w1FiKaJySeirttS7c1yT3Ebay4LQ8qaP19FhDnreu9CCpm4EgezfPzXr2hoKkyHEElbFYavJn_7Wepl_kd"]);
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    setState(() {
      isLoading =false;
    });


  }

  Widget submitButton(){
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            setState(() {
              postDetailsToFirestore();
            });

          },
          child: Text(
            hideMainForm ? "SignUp" : "Next",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget subForm(){
    return Column(
      children: [
        DropdownButton(
            hint: Text("Choose Batch"),
            isExpanded: true,
            value: selectedBatch,
            items: batchData
                .map((e) => DropdownMenuItem(child: Text(e['batchName']), value: e['batchId'],))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedBatchId = value.toString();
                selectedBatch = value.toString();

              });
            }
        ),
        DropdownButton(
            hint: Text("Choose Department"),
            isExpanded: true,
            value: selectedDept,
            items: deptData
                .map((e) => DropdownMenuItem(child: Text(e['deptName']), value: e['deptId'],))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedDeptId = value.toString();
                selectedDept = value.toString();
              });
            }
        ),
        DropdownButton(
            hint: Text("Choose Batch"),
            isExpanded: true,
            value: selectedDiv,
            items: divData
                .map((e) => DropdownMenuItem(child: Text(e['divName']), value: e['divId'],))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedDivId = value.toString();
                selectedDiv = value.toString();
              });
            }
        ),
      ],
    );
  }
}
