import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/home_screen.dart';
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

void _getCurrentUser() async {
  FirebaseUser _user = await FirebaseAuth.instance.currentUser();
  print(_user.uid);
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
            // return MainScreen(firestore: firestore,
            //     uuid: snapshot.data.uid);
            return ChatScreen(snapshot.data);
          }
          // log in user
          return LoginScreen(snapshot.data);
        }
      }
    );
  }

  Widget _splashScreen() {
    return Center(child: CircularProgressIndicator());
  }
}

