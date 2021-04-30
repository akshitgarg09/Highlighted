import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class HighlightsScreen extends StatelessWidget {
  static const routeName = 'highlightsScreen';
  List colors = [
    Colors.blueAccent,
    Colors.teal[600],
    Colors.red[700],
    Colors.grey[800],
    Colors.deepPurple[700]
  ];

  Random rnd = new Random();

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    final user = FirebaseAuth.instance.currentUser;
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final bookID = routeArgs['bookID'];
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Highlights',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(children: <Widget>[
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('books')
                    .doc(bookID)
                    .get(),
                builder: (ctx, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text(''));
                  }
                  if (bookSnapshot.hasData) {
                    final bookTitle = bookSnapshot.data.get('bookTitle');
                    final author = bookSnapshot.data.get('author');
                    return Container(
                        width: c_width,
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          Text(
                            bookTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, height: 1.5),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            author,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[700]),
                          )
                        ]));
                  }
                  return Center(
                    child: Text(''),
                  );
                }),
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('books')
                  .doc(bookID)
                  .collection('highlights')
                  .get(),
              builder: (ctx, highlightSnapshot) {
                if (highlightSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (highlightSnapshot.hasData) {
                  final List<DocumentSnapshot> highlights =
                      highlightSnapshot.data.docs;
                  final hLen = highlights.length;
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: highlights
                        .map((highlight) => Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 2.5,
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          color: colors[rnd.nextInt(5)],
                                          width: 7,
                                          height: 50,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  highlight['highlight'],
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            SizedBox(
              height: 40,
            )
          ]),
        ));
  }
}
