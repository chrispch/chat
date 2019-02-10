import 'package:flutter/material.dart';
import 'package:chat/pages/chat_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Chat',
     home: ChatScreen(),
   );
 }
}

