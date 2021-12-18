import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageCategory extends StatefulWidget {
  const ManageCategory({Key? key}) : super(key: key);

  @override
  _ManageCategoryState createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  var cateData = [];
  bool isLoading = true;
  final cateEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  fetchData(){
    cateData.clear();
    FirebaseFirestore.instance.collection('category').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        cateData.add(value.docs[i].data());
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
        title: const Text("Manage Categories"),
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
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ItemTile(
                      tileData: cateData,index: i,
                      removefuntion:(){
                        setState(() {
                          isLoading = true;
                          FirebaseFirestore.instance
                              .collection('category')
                              .doc(cateData[i]['cateId'])
                              .delete().then((value) => setState(() {
                            isLoading = false;
                            cateData.removeAt(i);
                          }));

                        });
                      }
                    );
                  },
                  itemCount: cateData.length,
                ),
                ElevatedButton(
                    onPressed: () {
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
                                    Center(child: Container(
                                      width: MediaQuery.of(context).size.width/1.4,
                                      child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          autofocus: false,
                                          controller: cateEditingController,
                                          validator: (value) {
                                            if (cateEditingController.text.isEmpty) {
                                              return "Batch Can't Be Empty";
                                            }
                                          },
                                          onSaved: (value) {
                                            cateEditingController.text = value!;
                                          },
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.message),
                                            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                            hintText: "Enter Category Name",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          )),
                                    )),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width/8),
                                      child: ElevatedButton(onPressed: (){
                                        if(cateEditingController.text != null ){
                                         var ref =  FirebaseFirestore.instance
                                              .collection('category').doc();
                                         print(ref.id);
                                          ref.set({
                                            "cateId": ref.id,
                                            "cateName": cateEditingController.text
                                          }).then((value) => setState(() {
                                            Navigator.pop(context);
                                            cateEditingController.text = "";
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
                    child: Text("Create New Cateogry"))
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
  bool isEditable = false;
  final textEditingController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    textEditingController.text = widget.tileData[widget.index]['cateName'];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isEditable
                  ? Container(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width / 3,
                      child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          autofocus: false,
                          controller: textEditingController,
                          validator: (value) {
                            if (textEditingController.text.isEmpty) {
                              return "Category Can't Be Empty";
                            }
                          },
                          onSaved: (value) {
                            textEditingController.text = value!;
                          },
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.message),
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            hintText: widget.tileData[widget.index]['cateName'],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )),
                    )
                  : Text("${widget.tileData[widget.index]['cateName']}"),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isEditable) {
                        setState(() {
                          isLoading = true;
                        });
                        FirebaseFirestore.instance
                            .collection('category')
                            .doc(widget.tileData[widget.index]['cateId'])
                            .set({
                          "cateId": widget.tileData[widget.index]['cateId'],
                          "cateName": textEditingController.text
                        }).then((value) => setState(() {
                                  isEditable = false;
                                  isLoading = false;
                                  widget.tileData[widget.index]['cateName'] =
                                      textEditingController.text;
                                }));
                      } else {
                        isEditable = !isEditable;
                      }
                    });
                  },
                  child: !isEditable ? Icon(Icons.edit) : Icon(Icons.save)),
              SizedBox(width: 5,),
              GestureDetector(
                  onTap: widget.removefuntion,
                  child: Icon(Icons.delete))
            ],
          );
  }
}
