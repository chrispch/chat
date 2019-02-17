import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final String photoUrl;
  final DocumentReference reference;
  
  User.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['email'] != null),
       assert(map['photoUrl'] != null),
       name = map['name'],
       photoUrl = map['photoUrl'],
       email = map['email'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "User<$name:$email>";
}