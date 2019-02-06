import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat/platform_adaptive.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
 {"name": "Filip", "votes": 15},
 {"name": "Abraham", "votes": 14},
 {"name": "Richard", "votes": 11},
 {"name": "Ike", "votes": 10},
 {"name": "Justin", "votes": 1},
];

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Chat',
     home: ChatScreen(),
   );
 }
}

class ChatScreen extends StatefulWidget {
 @override
 _ChatScreenState createState() {
   return _ChatScreenState();
 }
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  // DocumentReference _messagesReference = Firestore.instance.reference();
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  void _handlePhotoButtonPressed() {
    print("photo button pressed");
  }
  
  void _handleSubmitted(String text) {
    print("submit button pressed");
  }
  
  void _handleMessageChanged(String text) {
    print("message changed");
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(children: [
          Flexible(
              child: _buildChatList(context),
          ),
          Divider(height: 1.0),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer()),
        ]));
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: PlatformAdaptiveContainer(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _handlePhotoButtonPressed,
                ),
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  onChanged: _handleMessageChanged,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Send a message'),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: PlatformAdaptiveButton(
                    icon: Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                    child: Text('Send'),
                  )),
            ])));
  }
 
  Widget _buildChatList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('chat1').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final message = Message.fromSnapshot(data);
    return Padding(
      key: ValueKey(message.timestamp),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(message.sender),
          subtitle: Text(message.text),
          trailing: Text(DateFormat('yyyy').format(message.timestamp).toString()),
          onTap: () => print("clicked"),
          // Firestore.instance.runTransaction((transaction) async {
          //   final freshSnapshot = await transaction.get(message.reference);
          //   final fresh = Message.fromSnapshot(freshSnapshot);
          //   await transaction
          //       .update(message.reference, {'votes': fresh.votes + 1});
          // }),
        ),
      ),
    );
  }
}

class Message {
 final String text;
 final String sender;
 final DateTime timestamp;
 final DocumentReference reference;

 Message.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['sender'] != null),
       assert(map['text'] != null),
       assert(map['timestamp'] != null),
       sender = map['sender'],
       timestamp = map['timestamp'],
       text = map['text'];

 Message.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Message<$sender:$text>";
}