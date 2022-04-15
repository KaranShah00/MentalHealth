import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_health/screens/exercise_screen.dart';
import 'package:mental_health/screens/profile_screen.dart';
import 'package:mental_health/screens/stats_screen.dart';
import 'package:mental_health/screens/reminders_screen.dart';
import 'package:mental_health/screens/help_screen.dart';
import './music_screen.dart';
import './exercise_screen.dart';

class MyNavigationBar extends StatefulWidget {
  MyNavigationBar({Key? key}) : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  // final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
  }

  int focusedPage = 2;
  int previousPage = 2;
  static List<Widget> _widgetOptions = <Widget>[
    HelpScreen(),
    RemindersScreen(),
    HomeScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      previousPage = focusedPage;
      focusedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        reverse: previousPage > focusedPage,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            ),
        child: _widgetOptions.elementAt(focusedPage),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(0, -3),
          )
        ]),
        child: BottomNavigationBar(
          elevation: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.help,
              ),
              label: 'Help',
              backgroundColor: Color(0xff8000ff),
              // backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.schedule,
              ),
              label: 'Reminders',
              backgroundColor: Colors.pinkAccent,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
              backgroundColor: Color(0xff81dc17),
              // backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                // Icons.graphic_eq_rounded,
                Icons.timeline,
              ),
              label: 'Stats',
              backgroundColor: Color(0xffffba00),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
              ),
              label: 'Profile',
              backgroundColor: Color(0xff1d517c),
            ),
          ],
          currentIndex: focusedPage,
          iconSize: 20,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff81dc17),
        title: Text('Mental Wellness'),
        actions: [
          TextButton(
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => MusicScreen(),
              ),
            ),
            child: Text('Music'),
          ),
          ElevatedButton(
            onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ExerciseScreen();
                        }
                      ),
                    );
                  },
            child: Text('Exercise'),
          ),
        ],
      ),
    );
  }
}