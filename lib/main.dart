import 'package:flutter/material.dart';
import 'package:chat/pages/sign_up_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Chat',
     home: SignUpScreen({"name": "Chris Peh", "photoUrl": null}),
   );
 }
}

