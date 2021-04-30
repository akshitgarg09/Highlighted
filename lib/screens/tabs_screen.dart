import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './home_screen.dart';
import '../widgets/add_highlight.dart';
import './review_screen.dart';
import './stats_screen.dart';
import '../utils/authentication.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = 'tabsScreen';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  final user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    _pages = [
      {'page': HomeScreen(), 'title': 'Feed'},
      {'page': ReviewScreen(), 'title': 'Review'},
      {'page': StatsScreen(), 'title': 'Statistics'},
    ];
    // TODO: implement initState
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: _selectedPageIndex == 0
            ? FlatButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AddHighlight(),
                  );
                },
                child: Icon(
                  Icons.add_box_outlined,
                  color: Colors.black,
                ),
              )
            : null,
        title: _selectedPageIndex == 0
            ? Text(
                'Highlighted',
                style: TextStyle(color: Colors.black),
              )
            : FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (ctx, usersnapshot) {
                  if (usersnapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Username',
                      style: TextStyle(color: Colors.black),
                    );
                  }
                  var username = usersnapshot.data.get('username');

                  return Text(
                    username,
                    style: TextStyle(color: Colors.black),
                  );
                }),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              )
            ],
            onChanged: (valueIdentifier) {
              if (valueIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
                Authentication.signOut(context: context);
              }
            },
          )
        ],
      ),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey[700],
        selectedItemColor: Colors.blue,
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'Review'),
          BottomNavigationBarItem(
              icon: Icon(Icons.mobile_friendly), label: 'Statistics'),
        ],
      ),
    );
  }
}
