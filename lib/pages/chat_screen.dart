import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/helpers/platform_adaptive.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/message.dart';
import 'package:chat/pages/edit_profile_screen.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:firestore_ui/firestore_ui.dart';

class ChatScreen extends StatefulWidget {
  final User _user;
  ChatScreen(this._user);
  @override
  _ChatScreenState createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  Firestore _db = Firestore.instance;
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  // List<Message> _messages;

  void _handleEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(widget._user)),
    );
  }

  void _handlePhotoButtonPressed() {
    print("photo button pressed");
  }
  
  Future<Message> _handleSubmitted(String text) async {
    _textController.clear();

    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(_db.collection('chats').document('UAluilBWI4V129M2z8YX').collection('history').document());
      var dataMap = new Map<String, dynamic>();
      dataMap['sender'] = widget._user.name;
      dataMap['text'] = text;
      dataMap['timestamp'] = DateTime.now();

      setState(() {
        _isComposing = false;
      });
      await tx.set(ds.reference, dataMap);
      return dataMap;
    };
  
    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Message.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }
  
  void _handleMessageChanged(String text, StateSetter setter) {
    print("message changed");
    setter(() {
      _isComposing = text.length > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget._user?.name ?? "Chat"}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _handleEditProfile()
            )
        ]),
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
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
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
                    onChanged: (str) => _handleMessageChanged(str, setState),
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
    );
  }
 
  Widget _buildChatList(BuildContext context) {
    return FirestoreAnimatedList(
      reverse: true,
      query: Firestore.instance.collection('chats').document('UAluilBWI4V129M2z8YX').collection('history').orderBy('timestamp', descending:true).snapshots(),
      itemBuilder: (
        BuildContext context,
        DocumentSnapshot snapshot,
        Animation<double> animation,
        int index,
      ) {
          return FadeTransition(
            opacity: animation,
            child: ChatMessage(
              message: Message.fromSnapshot(snapshot),
              user: widget._user
              // onTap: _removeMessage,
            ),
          );
      }
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.message, this.user});
  final Message message;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                  backgroundImage: AdvancedNetworkImage(
                      user.photoUrl,
                      useDiskCache: true),
              )
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.sender,
                    style: Theme.of(context).textTheme.subhead),
                Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(message.text)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}