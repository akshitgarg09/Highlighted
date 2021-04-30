import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HighlightsScreen extends StatelessWidget {
  static const routeName = 'highlightsScreen';
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    final user = FirebaseAuth.instance.currentUser;
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final bookID = routeArgs['bookID'];
    return Scaffold(
        appBar: AppBar(
          title: Text('Highlights'),
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
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: highlights
                        .map((highlight) => Padding(
                              padding: const EdgeInsets.all(12.0),
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
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ]),
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
          ]),
        ));
  }
}
