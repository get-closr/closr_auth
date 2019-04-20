import 'package:closrauth/utils/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:closrauth/utils/crud.dart';

class SetupScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSetupComplete;
  final VoidCallback onSignedOut;

  SetupScreen({Key key, this.auth, this.onSignedOut, this.onSetupComplete})
      : super(key: key);

  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String username;
  String photoUrl;
  String deviceId = "closr_001";
  String partnerId;
  String userId;

  var users;

  CrudMedthods crudObj = CrudMedthods();

  get defaultPhotoUrl =>
      "https://thesocietypages.org/socimages/files/2009/05/nopic_192.gif";

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Data', style: TextStyle(fontSize: 15.0)),
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Enter User Name'),
                  onChanged: (value) {
                    this.username = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter photoUrl'),
                  onChanged: (value) {
                    this.photoUrl = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter deviceId'),
                  onChanged: (value) {
                    this.deviceId = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter partnerId'),
                  onChanged: (value) {
                    this.partnerId = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  crudObj.addData({
                    'username': this.username,
                    'userphoto': this.photoUrl,
                    'deviceId': this.deviceId,
                    'partnerId': this.partnerId,
                  }).then((result) {
                    dialogTrigger(context);
                  }).catchError((e) {
                    print(e);
                  });
                },
              )
            ],
          );
        });
  }

  Future<bool> dialogTrigger(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Job Done', style: TextStyle(fontSize: 15.0)),
            content: Text('Added'),
            actions: <Widget>[
              FlatButton(
                child: Text('Alright'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Update Data',
              style: TextStyle(fontSize: 15.0),
            ),
            content: Container(
              width: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: "Enter user name"),
                    onChanged: (value) {
                      this.username = value;
                    },
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter deviceId"),
                    onChanged: (value) {
                      this.deviceId = value;
                    },
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter partnerId"),
                    onChanged: (value) {
                      this.partnerId = value;
                    },
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter photoUrl"),
                    onChanged: (value) {
                      this.photoUrl = value;
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  crudObj.updateData(selectedDoc, {
                    'username': this.username,
                    'deviceId': this.deviceId,
                    'partnerId': this.partnerId,
                    'photoUrl': this.photoUrl
                  }).then((result) {
                    // dialogTrigger(context)
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    crudObj.getCurrentUserData().then((results) {
      setState(() {
        users = results;
      });
    });
    print(users);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Screen"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              addDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              crudObj.getCurrentUserData().then((results) {
                setState(() {
                  users = results;
                });
              });
            },
          ),
        ],
      ),
      body: _userDetails(),
    );
  }

  Widget _userDetails() {
    if (users != null) {
      return StreamBuilder(
          stream: users,
          builder: (BuildContext context, snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          snapshot.data.documents[index].data['photoUrl'] ??
                              defaultPhotoUrl),
                    ),
                    title: Text(
                        snapshot.data.documents[index].data['username'] ??
                            "Empty"),
                    subtitle: Column(
                      children: <Widget>[
                        Text(snapshot.data.documents[index].data['email'] ??
                            "Empty"),
                        Text(snapshot.data.documents[index].data['deviceId'] ??
                            "Empty"),
                        Text(snapshot.data.documents[index].data['partnerId'] ??
                            "Empty"),
                      ],
                    ),
                    onTap: () {
                      updateDialog(
                          context, snapshot.data.documents[index].documentID);
                    },
                    onLongPress: _onSetupComplete,
                  );
                },
              );
            } else {
              return Text("Something is wrong");
            }
          });
    } else {
      return Text('Loading, Please wait...');
    }
  }

  /*Todo
                      * check that no fields are null and return call onSetupComplete,
                      * transit to device control screen
                      * update per field not everything in Dialog
                      * add bluetooth update
                      */

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {}
  }

  void _onSetupComplete() {
    try {
      widget.onSetupComplete();
    } catch (e) {}
  }
}
