import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  String photoUrl;
  final String uid;
  final DocumentReference reference;
  
  User.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['email'] != null),
       assert(map['photoUrl'] != null),
       assert(map['uid'] != null),
       name = map['name'],
       photoUrl = map['photoUrl'],
       email = map['email'],
       uid = map['uid'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference:snapshot.reference);
  
  User.fromQuery(QuerySnapshot snapshot)
      : this.fromSnapshot(snapshot.documents.first);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _map = {};
    _map
    ..["name"] = name
    ..["email"] = email
    ..["photoUrl"] = photoUrl
    ..["uid"] = uid;
    return _map;
  }

  @override
  String toString() => "User<$name:$email>";
}