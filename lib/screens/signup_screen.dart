import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/authentication.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = 'signupPage';
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  bool _isLoading = false;

  void _trySubmit() async {
    UserCredential userCredential;

    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
    }

    try {
      setState(() {
        _isLoading = true;
      });

      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _userEmail, password: _userPassword);

      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user.uid)
          .set({'username': _userName, 'email': _userEmail});

      FirebaseFirestore.instance
          .collection('daily-review')
          .doc(userCredential.user.uid)
          .set({
        'index': 0,
        'last_attempted':
            DateFormat('d').format(DateTime.now().subtract(Duration(days: 2)))
      });

      FirebaseFirestore.instance
          .collection('review-stats')
          .doc(userCredential.user.uid)
          .set({'currentStreak': 0, 'longestStreak': 0});
    } on PlatformException catch (err) {
      var message = "An error occured, please check your credential.";

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ));

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);

      setState(() {
        _isLoading = false;
      });
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: FlatButton(
                      height: 50,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Sign up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 40, height: 1.5, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Let's create your account",
                    style: TextStyle(
                        fontSize: 20, height: 1.5, color: Colors.grey[700]),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty || value.length < 4) {
                        return 'Should be at least 4 char long';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2.5)),
                    ),
                    onSaved: (value) {
                      _userName = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2.5)),
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password should have atleast 7 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey[400], width: 2.5)),
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: RaisedButton(
                        color: Colors.blueAccent[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Sign Up',
                                style: TextStyle(color: Colors.white)),
                        onPressed: _trySubmit),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Or continue with',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.g_translate),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: Colors.grey[900])),
                        label: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Google',
                                style: TextStyle(color: Colors.grey[900])),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          User user = await Authentication.signInWithGoogle(
                              context: context);

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'username': user.displayName,
                            'email': user.email
                          });

                          FirebaseFirestore.instance
                              .collection('daily-review')
                              .doc(user.uid)
                              .set({
                            'index': 0,
                            'last_attempted': DateFormat('d').format(
                                DateTime.now().subtract(Duration(days: 2)))
                          });

                          FirebaseFirestore.instance
                              .collection('review-stats')
                              .doc(user.uid)
                              .set({'currentStreak': 0, 'longestStreak': 0});

                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.of(context).pop();
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
