import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  FirebaseUser _user;
  EditProfileScreen(this._user); 
  @override
  _EditProfileScreenState createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, dynamic> _providerInfo = {};
  
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a valid email';
    else
      return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
        ),
        body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
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
              initialValue: _providerInfo["name"]?? "",
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
              onSaved: (val) => _providerInfo["name"] = val
            ),
            TextFormField(
              initialValue: _providerInfo["email"]?? "",
              validator: validateEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                // hintText: 'This will be inked to your account',
                icon: const Icon(Icons.mail),
              ),
              onSaved: (val) => _providerInfo["email"] = val
            ),
            TextFormField(
              initialValue: _providerInfo["phoneNumber"]?? "",
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a valid phone number';
                }
              },
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: 'eg. +1 408-555-6969',
                icon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp(r'^[+()\d -]{1,15}$')),
              ],
              onSaved: (val) => _providerInfo["phoneNumber"] = val
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    print("form submitted!");
                    _formKey.currentState.save();
                    // navigate back to home_screen
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
      )),
    );
  }

  Widget _buildCircleAvatar (BuildContext context) {
    if (_providerInfo["photoUrl"] != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 4,
          backgroundImage: NetworkImage(_providerInfo["photoUrl"]),
        ),
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