import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_health/screens/exercise_screen.dart';
import 'package:mental_health/screens/facial_detection_screen.dart';
import 'package:mental_health/screens/profile_screen.dart';
import 'package:mental_health/screens/stats_screen.dart';
import 'package:mental_health/screens/reminders_screen.dart';
import 'package:mental_health/screens/help_screen.dart';
import './music_screen.dart';
import './exercise_screen.dart';
import './depression_questionnaire_screen.dart';
import './journal_screen.dart';
import './questionnaire_screen.dart';

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

  int focusedPage = 4;
  int previousPage = 4;
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
              backgroundColor: Color.fromARGB(255, 255, 64, 0),
              // backgroundColor: Colors.grey,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.schedule,
              ),
              label: 'Reminders',
              backgroundColor: Color.fromARGB(255, 84, 1, 193),
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
  var data;
  bool trackDataValue = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late String name = "";

  Map<String, List<Color>> color = {
    'red': [Color.fromARGB(255, 255, 111, 0),Color.fromARGB(255, 220, 23, 23),],
    'blue': [Color.fromARGB(255, 68, 175, 231),Color.fromARGB(255, 13, 42, 79)],
    'green': [Color.fromARGB(255, 115, 202, 0), Color.fromARGB(255, 20, 147, 3),],
    'yellow': [Color.fromARGB(255, 255, 217, 59),Color.fromARGB(255, 255, 186, 0),],
  };

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    data = firestore.collection('users').doc(user?.uid);
    data.get().then((value) {
      setState(() {
        name = value.data()!['username'];
        trackDataValue = value.data()!['track'];
        // _isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xff81dc17),
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
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 115, 202, 0),
                  Color.fromARGB(255, 20, 147, 3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 100,
            width: 450,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), //color of shadow
                  spreadRadius: 5, //spread radius
                  blurRadius: 7, // blur radius
                  offset: Offset(0, 2),
                )
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color.fromARGB(255, 175, 250, 0),Color.fromARGB(255, 50, 182, 3)]
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi ".toUpperCase() + name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 20,
                      // color: Colors.black,
                    ),
                  ),
                  Text(
                    "How are we feeling today?".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      // letterSpacing: 3,
                      fontSize: 15,
                      // color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: card("Depression Checker", color['blue'], Icon(Icons.face_retouching_natural_sharp, color: Colors.white, size: 40,)),
                  onTap:() => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return DepressionQuestionnaireScreen();
                    }),
                  )
                ),
                GestureDetector(
                  child: card("Mood Checker", color['green'], Icon(Icons.tag_faces_rounded, color: Colors.white, size: 40,)),
                  onTap:() => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return QuestionnaireScreen();
                    }),
                  )
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: card("My Journal", color['red'], Icon(Icons.menu_book, color: Colors.white, size: 40,)),
                  onTap:() => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return JournalScreen(trackDataValue);
                    }),
                  )
                ),
                GestureDetector(
                  child: card("Facial Detection", color['yellow'], Icon(Icons.face, color: Colors.white, size: 40,)),
                  onTap:() => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return FacialDetectionScreen();
                    }),
                  )
                ),
              ],
            ),
          ),
          // ElevatedButton(
          //   onPressed: () => Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (ctx) => MusicScreen(),
          //     ),
          //   ),
          //   child: Text('Music'),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) {
          //                 return ExerciseScreen();
          //               }
          //             ),
          //           );
          //         },
          //   child: Text('Exercise'),
          // ),
        ],
      ),
    );
  }

  Widget card(String title, List<Color>? color, Icon icon) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        height: 120,
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), //color of shadow
              spreadRadius: 5, //spread radius
              blurRadius: 7, // blur radius
              offset: Offset(0, 2),
            )
          ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: color!
            ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 10,),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                // letterSpacing: 3,
                fontSize: 18,
                // shadows: [
                //   Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 5)
                // ],
                color: Colors.white,
              ),
            ),
          ],
        )),
    );
  }
}