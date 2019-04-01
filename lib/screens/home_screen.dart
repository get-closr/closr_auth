import 'package:closrauth/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  HomeScreen({Key key, this.auth, this.onSignedOut}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _totalDocs = 0;
  var _queriedDocs = 0;
  var _interactionCount = 0;
  final _myContr = TextEditingController();
  final _getContr = TextEditingController();
  final _myUpdateContr = TextEditingController();
  bool _switchOnOff = false;
  var _listener;
  var _transactionListener;

  @override
  void dispose() {
    _myContr.dispose();
    _getContr.dispose();
    _myUpdateContr.dispose();
    _transactionListener.cancel();
    super.dispose();
  }

  void clickWrite() async {
    if (_myContr.text.isNotEmpty) {
      await Firestore.instance
          .collection('docs')
          .document()
          .setData({'text': _myContr.text});
      _myContr.text = '';
      interact();
    }
  }

  void clickUpdate(item) async {
    await Firestore.instance
        .collection('docs')
        .document(item.documentID)
        .updateData({'text': _myUpdateContr.text});
    interact();
    Navigator.pop(context);
  }

  void clickEdit(item) {
    _myUpdateContr.text = item['text'];
    showDialog(
        context: context,
        builder: (_) => SimpleDialog(
              title: Text('Edit text'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _myUpdateContr,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter new Text!'),
                        ),
                      ),
                      RaisedButton(
                        color: Colors.orange,
                        textColor: Colors.white,
                        splashColor: Colors.orangeAccent,
                        child: const Text('Update'),
                        onPressed: () {
                          clickUpdate(item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  void clickGet() async {
    if (_getContr.text.isNotEmpty) {
      var query = await Firestore.instance
          .collection('docs')
          .where('text', isEqualTo: _getContr.text)
          .getDocuments();
      setState(() {
        _queriedDocs = query.documents.length;
      });
      interact();
    }
  }

  void removeFromDb(itemID) {
    Firestore.instance.collection('docs').document(itemID).delete();
    interact();
  }

  void switchListener(isOn) async {
    bool switcher;
    switch (isOn) {
      case true:
        switcher = true;
        _listener = Firestore.instance
            .collection('docs')
            .snapshots()
            .listen((data) => listenerUpdate(data));
        break;
      case false:
        switcher = false;
        await _listener.cancel();
        break;
    }
    setState(() {
      _switchOnOff = switcher;
    });
  }

  void listenerUpdate(data) {
    var number = data.documents.length;
    setState(() {
      _totalDocs = number;
    });
  }

  @override
  void initState() {
    super.initState();
    _transactionListener = Firestore.instance
        .collection('stats')
        .document('interactions')
        .snapshots()
        .listen((data) => transactionListenerUpdate(data));
  }

  void transactionListenerUpdate(data) {
    var number = data['count'];
    setState(() {
      _interactionCount = number;
    });
  }

  void interact() async {
    final DocumentReference postRef =
        Firestore.instance.collection('stats').document('interactions');
    try {
      await Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(postRef);
        print(postSnapshot.exists);
        if (postSnapshot.exists) {
          final newVal = 1 + postSnapshot['count'];
          print('Updating counter value ' + newVal.toString());
          await tx.update(postRef, {'count': newVal});
          print('actually updated');
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Firestore Tutorial'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: _signOut,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: Text('Total Interactions: $_interactionCount')),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _myContr,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Enter Text'),
                  ),
                ),
                RaisedButton(
                  color: Colors.cyan,
                  textColor: Colors.white,
                  splashColor: Colors.cyanAccent,
                  child: const Text('Write to Firestore'),
                  onPressed: clickWrite,
                ),
              ],
            ),
            Divider(),
            Center(
              child:
                  Text('Get Number of Docs with specific Text: $_queriedDocs'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _getContr,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Enter Text'),
                  ),
                ),
                RaisedButton(
                  color: Colors.amber,
                  textColor: Colors.white,
                  splashColor: Colors.amberAccent,
                  child: const Text('Get'),
                  onPressed: clickGet,
                ),
              ],
            ),
            Divider(),
            Center(child: Text('Documents in Store: $_totalDocs')),
            Row(
              children: <Widget>[
                Expanded(child: Text('Turn on Listener')),
                Switch(
                    value: _switchOnOff,
                    onChanged: (val) {
                      switchListener(val);
                    }),
              ],
            ),
            Divider(),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('docs').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      switch (snapshot.data) {
                        case null:
                          return Container();
                        default:
                          return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                final item = snapshot.data.documents[index];
                                final itemID =
                                    snapshot.data.documents[index].documentID;
                                final list = snapshot.data.documents;
                                return Dismissible(
                                  key: Key(itemID),
                                  onDismissed: (direction) {
                                    removeFromDb(itemID);
                                    setState(() {
                                      list.removeAt(index);
                                    });
                                  },
                                  // Show a red background as the item is swiped away
                                  background: Container(color: Colors.red),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListTile(
                                          title: Text(item['text']),
                                        ),
                                      ),
                                      RaisedButton(
                                        color: Colors.blue,
                                        textColor: Colors.white,
                                        splashColor: Colors.blueAccent,
                                        child: const Text('Edit'),
                                        onPressed: () {
                                          clickEdit(item);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                      }
                    }))
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {}
  }
}
