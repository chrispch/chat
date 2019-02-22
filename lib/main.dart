import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat_screen.dart';
import 'package:chat/pages/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
    title: 'Chat',
    home: _handleCurrentScreen()
  );
 }

 Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        print("auth state changed");
        print(snapshot.data?.uid?? "user not logged in");
        // _getCurrentUser();
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading screen
          return _splashScreen();
        } else {
          if (snapshot.hasData) {
            // user logged in
            return FutureBuilder(future: Firestore.instance.collection('users').where("uid", isEqualTo: snapshot.data.uid).getDocuments(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) { return CircularProgressIndicator(); };
              return ChatScreen(User.fromQuery(snapshot.data));
            });
          }
          // log in user
          return LoginScreen();
        }
      }
    );
  }

  Widget _splashScreen() {
    return Center(child: CircularProgressIndicator());
  }
}

