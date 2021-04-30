import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import './tabs_screen.dart';

class HighlightAdded extends StatefulWidget {
  static const routeName = 'added';

  @override
  _HighlightAddedState createState() => _HighlightAddedState();
}

class _HighlightAddedState extends State<HighlightAdded> {
  String highlight;
  String coverImage;
  String author;
  String bookTitle;
  String bookID;
  final user = FirebaseAuth.instance.currentUser;

  List colors = [
    Colors.blueAccent,
    Colors.teal[600],
    Colors.red[700],
    Colors.grey[800],
    Colors.deepPurple[700]
  ];

  Random rnd = new Random();

  void _submit() async {
    DocumentReference docref;

    try {
      // TODO: NOT NECESSARY IF BOOK IS ALREADY THERE
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .doc(bookID)
          .set({
        'bookTitle': bookTitle,
        'author': author,
        'coverImage': coverImage
      });

      DocumentReference hId = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .doc(bookID)
          .collection('highlights')
          .add({'highlight': highlight, 'userID': user.uid});

      FirebaseFirestore.instance
          .collection('highlights')
          .doc(user.uid)
          .collection('userHighlights')
          .doc(hId.id)
          .set({
        'highlight': highlight,
        'dateCreated': DateTime.now().toString(),
        'bookID': bookID
      });
    } catch (err) {
      print(err.toString());
    }

    Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    highlight = routeArgs['highlight'];
    bookTitle = routeArgs['bookTitle'];
    coverImage = routeArgs['bookCover'];
    author = routeArgs['author'];
    bookID = routeArgs['bookID'];

    print('bookID: ' + bookID);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  Container(
                    color: Colors.blue[900],
                    height: 150,
                  ),
                  Positioned.fill(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      child: FlatButton(
                        color: Colors.white,
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 17),
                        ),
                        onPressed: _submit,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        coverImage,
                        width: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'New highlight added!',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      )
                    ],
                  )
                ]),
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('books')
                    .doc(bookID)
                    .collection('highlights')
                    .get(),
                builder: (ctx, highlightsSnaphot) {
                  if (highlightsSnaphot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Text(''),
                    );
                  }
                  if (highlightsSnaphot.hasData) {
                    final List<DocumentSnapshot> highlights =
                        highlightsSnaphot.data.docs;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: 350,
                            child: Card(
                                elevation: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          highlight,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ]),
                                )),
                          ),
                          ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: highlights
                                .map((highlight) => Container(
                                      width: 300,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 20),
                                      child: Card(
                                        elevation: 2.5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  highlight['highlight'],
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              ]),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Text(''),
                  );
                })
          ],
        ),
      ),
    );
  }
}
