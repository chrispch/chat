import 'package:cloud_firestore/cloud_firestore.dart';

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
       timestamp = map['timestamp'].toDate(),
       text = map['text'];

 Message.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Message<$sender:$text>";
}