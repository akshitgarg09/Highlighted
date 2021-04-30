import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './highlights_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.7;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('books')
          .snapshots(),
      builder: (ctx, bookSnapshot) {
        if (bookSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (bookSnapshot.hasData) {
          final books = bookSnapshot.data.docs;
          return ListView.builder(
              itemCount: books.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          HighlightsScreen.routeName,
                          arguments: {'bookID': books[index].id}),
                      child: Row(
                        children: <Widget>[
                          Image.network(
                            books[index]['coverImage'],
                            width: 80,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            width: c_width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  books[index]['bookTitle'],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  books[index]['author'],
                                  style: TextStyle(color: Colors.grey[700]),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                );
              });
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
