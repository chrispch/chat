import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/platform_adaptive.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/message.dart';
import 'package:chat/pages/edit_profile_screen.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';

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
  
  void _handleMessageChanged(String text) {
    print("message changed");
    setState(() {
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
      stream: Firestore.instance.collection('chats').document('UAluilBWI4V129M2z8YX').collection('history').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
          // reverse: true,
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final message = Message.fromSnapshot(data);
    final AnimationController _animationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    // _animationController.forward();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                  backgroundImage: AdvancedNetworkImage(
                      widget._user.photoUrl,
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