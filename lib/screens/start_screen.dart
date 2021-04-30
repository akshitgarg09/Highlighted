import 'package:flutter/material.dart';

import './login_screen.dart';
import './signup_screen.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'Highlighted',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(
                height: 300,
              ),
              Text(
                'For adventury readers',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Your smart library in your pocket.\n Any time. Any place',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: RaisedButton(
                    color: Colors.grey[900],
                    child: Text(
                      'Create an account',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(SignupScreen.routeName);
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey[900])),
                    child: Text('Login',
                        style: TextStyle(color: Colors.grey[900])),
                    onPressed: () {
                      Navigator.of(context).pushNamed(LoginScreen.routeName);
                    }),
              ),
            ]),
      ),
    );
  }
}
