import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseUser _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;  
  Firestore _db = Firestore.instance;

  @override
  initState() {
    super.initState();
    print("loaded login screen");
    // attempt to sign in user
    _authenticateWithGoogle();
  }

  void _authenticateWithGoogle() async {
    print("authenticating...");
    final GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = 
            await _googleUser.authentication;
    final AuthCredential _credential = GoogleAuthProvider.getCredential(
      accessToken: _googleAuth.accessToken,
      idToken: _googleAuth.idToken,
    );
    _user = await
            _auth.signInWithCredential(_credential);
    print(_user.uid);
    QuerySnapshot _usersWithSameEmail = await _db.collection('users').where('email', isEqualTo: _user.providerData[0].email).getDocuments();
    if (_usersWithSameEmail.documents.length == 0) {
      _updateUserProfile();
    }
  }

  Future<User> _updateUserProfile () async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(_db.collection('users').document());
  
      var dataMap = new Map<String, dynamic>();
      dataMap['name'] = _user.providerData[0].displayName;
      dataMap['email'] = _user.providerData[0].email;
      dataMap['photoUrl'] = _user.providerData[0].photoUrl;

      await tx.set(ds.reference, dataMap);
  
      return dataMap;
    };
  
    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return User.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  Widget build (BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}