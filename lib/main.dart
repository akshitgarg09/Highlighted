import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/tabs_screen.dart';
import 'screens/start_screen.dart';
import './screens/highlight_added_screen.dart';
import './screens/highlights_screen.dart';
import './widgets/add_via_text.dart';
import './screens/review_screen.dart';
import './screens/daily_review.dart';
import './screens/stats_screen.dart';
import './screens/settings.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  String highlight;
  String bookCover;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, appSnapshot) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Merriweather'),
            home: appSnapshot.connectionState != ConnectionState.done
                ? SplashScreen()
                : StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      }
                      if (userSnapshot.hasData) {
                        return TabsScreen();
                      }
                      return StartScreen();
                    }),
            routes: {
              AddViaText.routeName: (ctx) => AddViaText(),
              HighlightAdded.routeName: (ctx) => HighlightAdded(),
              TabsScreen.routeName: (ctx) => TabsScreen(),
              HighlightsScreen.routeName: (ctx) => HighlightsScreen(),
              ReviewScreen.routeName: (ctx) => ReviewScreen(),
              DailyReview.routeName: (ctx) => DailyReview(),
              StatsScreen.routeName: (ctx) => StatsScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              SignupScreen.routeName: (ctx) => SignupScreen()
            });
      },
    );
  }
}
