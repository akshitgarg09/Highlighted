import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../utils/authentication.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'loginPage';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPassword = '';
  bool _isLoading = false;

  void _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userEmail, password: _userPassword);
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
                    height: 60,
                  ),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                        fontSize: 40, height: 1.5, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "We've been waiting for you",
                    style: TextStyle(
                        fontSize: 20, height: 1.5, color: Colors.grey[700]),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email address',
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
                            : Text('Login',
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
                        label: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Continue with google'),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          User user = await Authentication.signInWithGoogle(
                              context: context);

                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.of(context).pop();
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
