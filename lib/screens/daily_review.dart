import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DailyReview extends StatefulWidget {
  static const routeName = 'daily-review';
  @override
  _DailyReviewState createState() => _DailyReviewState();
}

class _DailyReviewState extends State<DailyReview>
    with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  var lastAttempted;
  var index;
  final now = DateTime.now();
  var currentStreak;
  var longestStreak;
  final PageController controller = PageController(initialPage: 0);
  int currentPage = 0;

  Animation<double> _progressAnimation;
  AnimationController _progressAnimcontroller;

  @override
  void initState() {
    super.initState();

    _progressAnimcontroller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: beginWidth, end: endWidth)
        .animate(_progressAnimcontroller);

    _setProgressAnim(0, 1);
  }

  void _onPageChanged(int page) {
    currentPage = page;
    print('currentpage: ${currentPage}');
  }

  double growStepWidth, beginWidth, endWidth = 0.0;
  int totalPages = 3;

  _setProgressAnim(double maxWidth, int curPageIndex) {
    setState(() {
      growStepWidth = maxWidth / totalPages;
      beginWidth = growStepWidth * (curPageIndex - 1);
      endWidth = growStepWidth * curPageIndex;

      _progressAnimation = Tween<double>(begin: beginWidth, end: endWidth)
          .animate(_progressAnimcontroller);
    });

    _progressAnimcontroller.forward();
  }

  void _reviewDone() async {
    FirebaseFirestore.instance.collection('daily-review').doc(user.uid).set({
      'last_attempted': DateFormat('d').format(DateTime.now()),
      'index': index + 3
    });

    FirebaseFirestore.instance
        .collection('review-stats')
        .doc(user.uid)
        .collection('userReviews')
        .doc(DateFormat('dd-MM-yyyy').format(DateTime.now()))
        .set({'status': 'done'});

    final reviewRef =
        FirebaseFirestore.instance.collection('review-stats').doc(user.uid);

    if (lastAttempted ==
        DateFormat('d').format(now.subtract(Duration(days: 1)))) {
      await reviewRef.update({'currentStreak': FieldValue.increment(1)});
    } else if (lastAttempted != DateFormat('d').format(DateTime.now())) {
      await reviewRef.update({'currentStreak': 1});
    }

    final snapshot = await reviewRef.get();
    currentStreak = snapshot['currentStreak'];
    longestStreak = snapshot['longestStreak'];
    if (currentStreak > longestStreak) {
      reviewRef.update({'longestStreak': currentStreak});
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQD = MediaQuery.of(context);
    var maxWidth = mediaQD.size.width;
    double t_width = MediaQuery.of(context).size.width * 0.6;
    print('now: ' + DateFormat('d').format(now.subtract(Duration(days: 1))));
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    lastAttempted = routeArgs['lastAttempted'];
    index = routeArgs['index'];
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Daily Review',
            style: TextStyle(color: Colors.black),
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 1.0),
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  AnimatedProgressBar(
                    animation: _progressAnimation,
                  ),
                  Expanded(
                    child: Container(
                      height: 6.0,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            FlatButton(
                onPressed: () {},
                child: Text(
                  currentPage == 0
                      ? '0'
                      : currentPage == 1
                          ? '1'
                          : '2',
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('highlights')
                .doc(user.uid)
                .collection('userHighlights')
                .orderBy('dateCreated')
                .snapshots(),
            builder: (ctx, highlightsSnapshot) {
              if (highlightsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (highlightsSnapshot.hasData) {
                final highlights = highlightsSnapshot.data.docs;
                final l = highlights.length;
                if (l < 4) {
                  return Center(
                    child: Text(
                        'Start reviewing your highlights by adding few first.'),
                  );
                } else {
                  return PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    itemCount: 3,
                    itemBuilder: (ctx, i) {
                      final bookId = highlights[(index + i) % l]['bookID'];
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('books')
                              .doc(bookId)
                              .snapshots(),
                          builder: (ctx, bookSnapshot) {
                            if (bookSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (bookSnapshot.hasData) {
                              final author = bookSnapshot.data.get('author');
                              final bookTitle =
                                  bookSnapshot.data.get('bookTitle');
                              final coverImage =
                                  bookSnapshot.data.get('coverImage');
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 350,
                                          child: Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Center(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.network(
                                                            coverImage,
                                                            width: 40,
                                                          ),
                                                          SizedBox(
                                                            width: 20,
                                                          ),
                                                          Container(
                                                            width: t_width,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      bookTitle),
                                                                  SizedBox(
                                                                    height: 7,
                                                                  ),
                                                                  Text(
                                                                    author,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  )
                                                                ]),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(highlights[
                                                              (index + i) % l]
                                                          ['highlight'])
                                                    ]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      FloatingActionButton(
                                          elevation: 2.5,
                                          backgroundColor: Colors.blueAccent,
                                          child: Icon(Icons.done),
                                          onPressed: () {
                                            if (i != 2) {
                                              controller.animateToPage(i + 1,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease);
                                            } else {
                                              _reviewDone();
                                            }
                                          })
                                    ]),
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                    },
                  );
                }
              }

              return Center(
                child: Text('Loading...'),
              );
            }));
  }
}

class AnimatedProgressBar extends AnimatedWidget {
  AnimatedProgressBar({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      height: 6.0,
      width: animation.value,
      decoration: BoxDecoration(color: Colors.red),
    );
  }
}
