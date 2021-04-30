import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'daily_review.dart';

class ReviewScreen extends StatefulWidget {
  static const routeName = 'review';
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('daily-review')
            .doc(user.uid)
            .snapshots(),
        builder: (ctx, reviewSnapshot) {
          if (reviewSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (reviewSnapshot.hasData) {
            final lastAttempted = reviewSnapshot.data.get('last_attempted');
            final index = reviewSnapshot.data.get('index');

            return InkWell(
              splashColor: Colors.blue,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                ),
                padding: EdgeInsets.all(20),
                height: 300,
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('yMMMd').format(DateTime.now()),
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Daily Review',
                        style: TextStyle(color: Colors.white, fontSize: 35)),
                    SizedBox(
                      height: 140,
                    ),
                    lastAttempted == DateFormat('d').format(DateTime.now())
                        ? Text("You've completed today's review!",
                            style: TextStyle(color: Colors.white, fontSize: 15))
                        : Text(''),
                  ],
                ),
              ),
              onTap: () => Navigator.of(context).pushNamed(
                  DailyReview.routeName,
                  arguments: {'lastAttempted': lastAttempted, 'index': index}),
            );
          }
          return Center(
            child: Text('Loading...'),
          );
        });
  }
}
