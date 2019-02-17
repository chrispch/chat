import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  Firestore _db = Firestore.instance;
  // FirebaseUser _user;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<FirebaseUser> _handleSignIn() async {
    // go to sign in screen where you can enter phone number and verification code

  //   final AuthCredential credential = GoogleAuthProvider.getCredential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
    
  //   final FirebaseUser user = await _auth.signInWithCredential(credential);
  //   print(user);
    
  //   final query = _db.collection('users').where('uid', isEqualTo: user.uid);
  //   query.getDocuments().then((querySnapshot) {
  //     if (querySnapshot.documents.isEmpty) {
  //       print("no matches");
  //       print(user.uid);
  //     }
  //     else {
  //       print("it is a match!");
  //     }
  //   });

  //   // If user already logged in (restart app)
  //   setState(() {
  //     _user = user;
  //   });
  //   print("signed in " + _user.displayName);

  //   return user;
  // }

  // Future<FirebaseUser> _handleSignUp(FirebaseUser user) async {
  //   // populate email, name, phonenumber, photo
  //   // init invites, chats
  //   final Map<String, dynamic> _providerInfo = {};
  //   final UserInfo _provider = user.providerData[0];
  //   _providerInfo["email"] = _provider.email;
  //   _providerInfo["photoUrl"] = _provider.photoUrl;
  //   _providerInfo["name"] = _provider.displayName;
  //   _providerInfo["phoneNumber"] = _provider.phoneNumber;
  // }

  @override
  void initState () {
    if (_auth.currentUser == null) {
      // attempt sign in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_user?.displayName ?? "Chat"}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _handleSignIn()
              .then((FirebaseUser user) => () {
                print("successfully signed in");
              })
              .catchError((e) => print(e)),)
      ]),
      body: Column(children: [
          Flexible(
              child: Text("placeholder"),
          ),
          Divider(height: 1.0),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: Text("placeholder")),
        ]));
  }
}

class User {
  final String email;
  final String name;
  final String photoUrl;
  final String uid;
  final String phoneNumber;
  final List<Map<String, String>> invites;
  final List<String> chats;

  User.fromMap(Map<String, dynamic> map)
     : assert(map['email'] != null),
       assert(map['name'] != null),
       assert(map['photoUrl'] != null),
       assert(map['uid'] != null),
       assert(map['phoneNumber'] != null),
       email = map['email'],
       name = map['name'],
       photoUrl = map['photoUrl'],
       uid = map['uid'],
       phoneNumber = map['phoneNumber'],
       invites = map['invites'],
       chats = map['chats'];

  // User(this.email, this.password, this.name, this.photoUrl, this.uid, this.phoneNumber, this.invites, this.chats);

}