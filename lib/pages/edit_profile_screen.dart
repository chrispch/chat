import 'package:chat/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final FirebaseUser _user;
  EditProfileScreen(this._user);
  @override
  _EditProfileScreenState createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Firestore _db = Firestore.instance;
  final Map<String, dynamic> _providerInfo = {};
  User _profile;

  @override
  initState() {
    super.initState();
    _db.collection('users').where("uid", isEqualTo: widget._user.uid).snapshots()
      .listen((data) {
        data.documents.forEach((document) {
          setState(() {
            _profile = User.fromSnapshot(document);
            // print(_profile.toString());
          });
        });
      });
  }

  Future<User> _updateProfile () async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(_profile.reference);
      var dataMap = _profile.toMap();
      await tx.set(ds.reference, dataMap);
      return dataMap;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return User.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a valid email';
    else
      return null;
  }

  void _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> _signOutAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Your data is kept safely in the cloud'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: FlatButton(
                child: Text('SIGN OUT', style:TextStyle(color: Colors.red)),
                onPressed: () {
                  _handleSignOut();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOutAlert(),
          )
        ]),
        body: Builder(
          builder: (BuildContext context) {
            return _buildForm(context);
          })
    );
  }

  Widget _buildForm(BuildContext context) {
    if (_profile == null) {
      return Center(child: CircularProgressIndicator());
    }
    else {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildCircleAvatar(context),
              TextFormField(
                initialValue: _profile?.name?? "",
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Display name',
                  // hintText: '...',
                  icon: const Icon(Icons.person),
                ),
                onSaved: (val) => _profile.name = val
              ),
              TextFormField(
                initialValue: _profile?.email?? "",
                validator: validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  // hintText: 'This will be inked to your account',
                  icon: const Icon(Icons.mail),
                ),
                onSaved: (val) => _profile.email = val
              ),
              // Disused input for phone number
              Container(
                // child: TextFormField(
                //   initialValue: _providerInfo["phoneNumber"]?? "",
                //   validator: (value) {
                //     if (value.isEmpty) {
                //       return 'Please enter a valid phone number';
                //     }
                //   },
                //   decoration: InputDecoration(
                //     labelText: 'Phone number',
                //     hintText: 'eg. +1 408-555-6969',
                //     icon: const Icon(Icons.phone),
                //   ),
                //   keyboardType: TextInputType.phone,
                //   inputFormatters: [
                //     WhitelistingTextInputFormatter(RegExp(r'^[+()\d -]{1,15}$')),
                //   ],
                //   onSaved: (val) => _providerInfo["phoneNumber"] = val
                // ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      print("form submitted!");
                      _formKey.currentState.save();
                      _updateProfile();
                      Scaffold.of(context).showSnackBar(new SnackBar(
                          content: Text(
                            "Updated profile",
                            style: TextStyle(fontSize: 16)
                            ),
                      ));
                    }
                  },
                  child: Text('Update'),
                ),
              ),
            ],
        )),
      );
    }
  }

  Widget _buildCircleAvatar (BuildContext context) {
    double _radius = MediaQuery.of(context).size.width / 4;
    if (_profile.photoUrl != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: _radius,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: CachedNetworkImage(
                imageUrl: _profile.photoUrl,
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
                fit:BoxFit.cover,
                width: _radius * 2,
                height: _radius * 2,
              ),
          ),
        )
      );
    }
    else {
      String _initials = "";
      if (_providerInfo["name"] != null) {
        final List<String> _nameWords = _providerInfo["name"].split(' ');
        _nameWords.forEach((val) => _initials = _initials + val[0]);
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 4,
          child: Text(_initials?? "?",
            style: TextStyle(fontSize: 40)
          )
        ),
      );
    }
  }
}