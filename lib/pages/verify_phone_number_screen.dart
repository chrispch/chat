import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class VerifyPhoneNumberScreen extends StatefulWidget {
  // final Map<String, dynamic> _providerInfo;
  // VerifyPhoneNumberScreen(this._providerInfo);
  @override
  _VerifyPhoneNumberScreenState createState() {
    return _VerifyPhoneNumberScreenState();
  }
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  Future<String> _message = Future<String>.value('placeholder');
  final String testSmsCode = '123456';
  final String testPhoneNumber = '+65 96790576';
  TextEditingController _smsCodeController = TextEditingController();
  String verificationId;

  Future<void> _testVerifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      setState(() {
        _message =
            Future<String>.value('signInWithPhoneNumber auto succeeded: $user');
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message = Future<String>.value(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      _smsCodeController.text = testSmsCode;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: testPhoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<String> _testSignInWithPhoneNumber(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    _smsCodeController.text = '';
    return 'signInWithPhoneNumber succeeded: $user';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Verify Number"),
        ),
        body: Column(
          children: <Widget>[
            FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Text(snapshot.data ?? '',
                    style:
                        const TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
            }),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
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
                      onSaved: (val) => print(val)
                  ),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                    child: Text("SEND"),
                    onPressed: () => _testVerifyPhoneNumber(),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your verification code';
                        }
                      },
                      controller: _smsCodeController,
                      decoration: InputDecoration(
                        labelText: 'Verification code',
                        hintText: 'eg. 234785',
                        icon: const Icon(Icons.code),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                  ),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                    child: Text("VERIFY"),
                    onPressed: () => _testVerifyPhoneNumber(),
                  ),
                )
              ],
            ),
          ],
        ),
    );
  }
}