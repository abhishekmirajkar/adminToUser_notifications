import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageDiv extends StatefulWidget {
  const ManageDiv({Key? key}) : super(key: key);

  @override
  _ManageDivState createState() => _ManageDivState();
}

class _ManageDivState extends State<ManageDiv> {
  var divData = [];
  bool isLoading = true;
  final divEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  fetchData(){
    divData.clear();
    FirebaseFirestore.instance.collection('divisions').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        divData.add(value.docs[i].data());
      }
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Notice Board"),
        leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator.adaptive(),
      )
          : Column(
        children: [
          SizedBox(height: 10,),
          Text("Division Details",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),),

          SizedBox(height: 10,),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return ItemTile(
                  tileData: divData,index: i,
                  removefuntion:(){
                    setState(() {
                      isLoading = true;
                      FirebaseFirestore.instance
                          .collection('divisions')
                          .doc(divData[i]['divId'])
                          .delete().then((value) => setState(() {
                        isLoading = false;
                        divData.removeAt(i);
                      }));

                    });
                  }
              );
            },
            itemCount: divData.length,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 16,
                            child: Container(
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  Form(key: _formKey,child: Container(
                                    width: MediaQuery.of(context).size.width/1.4,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        autofocus: false,
                                        controller: divEditingController,
                                        validator: (value) {
                                          if (divEditingController.text.isEmpty) {
                                            return "Division Can't Be Empty";
                                          }
                                        },
                                        onSaved: (value) {
                                          divEditingController.text = value!;
                                        },
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.message),
                                          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                          hintText: "Enter Division Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        )),
                                  )),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width/8.5),
                                    child: ElevatedButton(onPressed: (){
                                      if(_formKey.currentState!.validate() && divEditingController.text != null ){
                                        setState(() {
                                          isLoading = true;
                                        });
                                        var ref =  FirebaseFirestore.instance
                                            .collection('divisions').doc();
                                        print(ref.id);
                                        ref.set({
                                          "divId": ref.id,
                                          "divName": divEditingController.text
                                        }).then((value) => setState(() {
                                          Navigator.pop(context);
                                          divEditingController.text = "";
                                          fetchData();
                                        }));
                                      }
                                    }, child: Text("Save")),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right:38.0),
                    child: Text("Add Division +",style: TextStyle(fontSize: 18,decoration: TextDecoration.underline,),),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class ItemTile extends StatefulWidget {
  var tileData;
  int index;
  VoidCallback? removefuntion;
  ItemTile({Key? key, required this.tileData,required this.index,this.removefuntion}) : super(key: key);

  @override
  _ItemTileState createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  bool isEditable = true;
  final textEditingController = TextEditingController();
  bool isLoading = false;
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    textEditingController.text = widget.tileData[widget.index]['divName'];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
      child: CircularProgressIndicator.adaptive(),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey1,
            child: Container(
              width: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width / 3,
              child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  autofocus: false,
                  controller: textEditingController,
                  validator: (value) {
                    if (textEditingController.text.isEmpty) {
                      return "Division Can't Be Empty";
                    }
                  },
                  onChanged: (value) {
                    isEditable = false;
                  },
                  onSaved: (value) {
                    textEditingController.text = value!;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    hintText: widget.tileData[widget.index]['divName'],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
            ),
          ),
          SizedBox(width: 10,),
          GestureDetector(
              onTap: () {
                setState(() {
                  if (_formKey1.currentState!.validate() && isEditable) {
                    setState(() {
                      isLoading = true;
                    });
                    FirebaseFirestore.instance
                        .collection('divisions')
                        .doc(widget.tileData[widget.index]['divId'])
                        .set({
                      "divId": widget.tileData[widget.index]['divId'],
                      "divName": textEditingController.text
                    }).then((value) => setState(() {
                      isEditable = false;
                      isLoading = false;
                      widget.tileData[widget.index]['divName'] =
                          textEditingController.text;
                    }));
                  } else {
                    isEditable = !isEditable;
                  }
                });
              },
              child:  Icon(Icons.save,color: Theme.of(context).primaryColor,size: 30)),
          SizedBox(width: 5,),
          GestureDetector(
              onTap: widget.removefuntion,
              child: Icon(Icons.delete,color: Colors.red,size: 30,))
        ],
      ),
    );
  }
}


// class _ItemTileState extends State<ItemTile> {
//   bool isEditable = false;
//   final textEditingController = TextEditingController();
//   bool isLoading = false;
//   @override
//   void initState() {
//     // TODO: implement initState
//     textEditingController.text = widget.tileData[widget.index]['divName'];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Center(
//       child: CircularProgressIndicator.adaptive(),
//     )
//         : Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         isEditable
//             ? Container(
//           width: MediaQuery.of(context).size.width -
//               MediaQuery.of(context).size.width / 3,
//           child: TextFormField(
//               keyboardType: TextInputType.multiline,
//               autofocus: false,
//               controller: textEditingController,
//               validator: (value) {
//                 if (textEditingController.text.isEmpty) {
//                   return "Division Can't Be Empty";
//                 }
//               },
//               onSaved: (value) {
//                 textEditingController.text = value!;
//               },
//               textInputAction: TextInputAction.done,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.message),
//                 contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//                 hintText: widget.tileData[widget.index]['divName'],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               )),
//         )
//             : Text("${widget.tileData[widget.index]['divName']}"),
//         GestureDetector(
//             onTap: () {
//               setState(() {
//                 if (isEditable) {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   FirebaseFirestore.instance
//                       .collection('divisions')
//                       .doc(widget.tileData[widget.index]['divId'])
//                       .set({
//                     "divId": widget.tileData[widget.index]['divId'],
//                     "divName": textEditingController.text
//                   }).then((value) => setState(() {
//                     isEditable = false;
//                     isLoading = false;
//                     widget.tileData[widget.index]['divName'] =
//                         textEditingController.text;
//                   }));
//                 } else {
//                   isEditable = !isEditable;
//                 }
//               });
//             },
//             child: !isEditable ? Icon(Icons.edit) : Icon(Icons.save)),
//         SizedBox(width: 5,),
//         GestureDetector(
//             onTap: widget.removefuntion,
//             child: Icon(Icons.delete))
//       ],
//     );
//   }
// }
