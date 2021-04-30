import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/highlight_added_screen.dart';

class AddViaText extends StatefulWidget {
  static const routeName = 'text';
  @override
  _AddViaTextState createState() => _AddViaTextState();
}

class _AddViaTextState extends State<AddViaText> {
  final _form = GlobalKey<FormState>();
  String searchKey;
  Stream streamQuery;
  final _highlightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;

    if (routeArgs != null) {
      final highlight = routeArgs['highlight'];
      _highlightController.text = highlight;
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Form(
                  key: _form,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        InputDecoration(labelText: 'Enter Highlight Text'),
                    controller: _highlightController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide an input.';
                      }
                      return null;
                    },
                  ),
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Search Book'),
                    onChanged: (value) {
                      setState(() {
                        searchKey = value;
                        print('searchKey: ' + searchKey);
                        streamQuery = searchKey.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('books')
                                .where('c_title',
                                    isGreaterThanOrEqualTo:
                                        searchKey.toLowerCase())
                                .where('c_title',
                                    isLessThan: searchKey.toLowerCase() + 'z')
                                .snapshots()
                            : null;
                      });
                    }),
                StreamBuilder(
                  stream: streamQuery,
                  builder: (ctx, booksSnapshot) {
                    if (booksSnapshot.data == null) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Enter a keyword',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      );
                    }

                    if (booksSnapshot.hasData) {
                      final books = booksSnapshot.data.docs;

                      return Container(
                        height: 200,
                        child: Scrollbar(
                          isAlwaysShown: true,
                          child: ListView.builder(
                              padding: EdgeInsets.all(12),
                              itemCount: books.length,
                              itemBuilder: (ctx, index) {
                                return FlatButton(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      books[index]['title'],
                                    ),
                                  ),
                                  onPressed: () {
                                    final _isValid =
                                        _form.currentState.validate();
                                    if (!_isValid) {
                                      return;
                                    }
                                    Navigator.of(context).pushNamed(
                                        HighlightAdded.routeName,
                                        arguments: {
                                          'highlight':
                                              _highlightController.text,
                                          'bookTitle': books[index]['title'],
                                          'bookCover': books[index]
                                              ['coverImage'],
                                          'author': books[index]['author'],
                                          'bookID': books[index].id
                                        });
                                  },
                                );
                              }),
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Enter a keyword',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
