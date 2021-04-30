import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../utils/authentication.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
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

      if (_isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _userEmail, password: _userPassword);
      } else {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _userEmail, password: _userPassword);

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({'username': _userName, 'email': _userEmail});
      }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Highlighted'),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Phone number, email address or username'),
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty || value.length < 4) {
                        return 'Should be at least 4 char long';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Username'),
                    onSaved: (value) {
                      _userName = value;
                    },
                  ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'Password should have atleast 7 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value;
                  },
                ),
                RaisedButton(
                    onPressed: _trySubmit,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(_isLogin ? 'Login' : 'Signup')),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin
                        ? 'Create a new account instead'
                        : 'Already have an account?')),
                RaisedButton(
                    child: _isLoading
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
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
