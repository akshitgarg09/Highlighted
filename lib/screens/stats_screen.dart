import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsScreen extends StatefulWidget {
  static const routeName = 'statistics';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  final user = FirebaseAuth.instance.currentUser;
  String exists = '';
  Future<void> itExists() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('review-stats')
        .doc(user.uid)
        .collection('userReviews')
        .doc(DateFormat('dd-MM-yyyy').format(_selectedDay))
        .get();

    if (documentSnapshot.exists) {
      setState(() {
        exists = 'You completed your Daily review on this day.';
      });
    } else {
      setState(() {
        exists = "You didn't complete your Daily Review on this day.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: study intistate
    itExists();
    if (_selectedDay != null) {
      print("selected day: " + DateFormat('dd-MM-yyyy').format(_selectedDay));
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(
              height: 20,
            ),
            _selectedDay != null ? Text(exists) : Text('Pick a date'),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('review-stats')
                  .doc(user.uid)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  final longestStreak = snapshot.data.get('longestStreak');
                  final currentStreak = snapshot.data.get('currentStreak');
                  return Column(children: <Widget>[
                    Container(
                      height: 100,
                      width: 350,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              longestStreak.toString() + ' Days',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Longest Streak All-Time')
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 100,
                      width: 350,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              currentStreak.toString() + ' Days',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Current Streak')
                          ],
                        ),
                      ),
                    ),
                  ]);
                }
                return Center(
                  child: Text(''),
                );
              },
            )
          ]),
        ),
      ),
    );
  }
}
