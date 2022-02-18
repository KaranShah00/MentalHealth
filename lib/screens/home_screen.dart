import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_health/screens/profile_screen.dart';
import 'package:mental_health/screens/stats_screen.dart';
import 'package:mental_health/screens/reminders_screen.dart';
import 'package:mental_health/screens/help_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import './reminder_screen.dart';
import '../widgets/notification_utils.dart';
import '../widgets/new_reminder.dart';

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
    // Workmanager.initialize(
    //   callbackDispatcher,
    //   isInDebugMode: true,
    // );

    // Workmanager.registerPeriodicTask(
    //   "1",
    //   fetchBackground,
    //   frequency: Duration(minutes: 15),
    // );
    
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
      // appBar: AppBar(
      //   backgroundColor: Color(0x77ffffff),
      //   title: Text('Mental Wellness'),
      //   actions: [
      //     FlatButton(
      //         child: Text('Logout'),
      //         onPressed: () {
      //           FirebaseAuth.instance.signOut();
      //         }),
      //   ],
      // ),
      // body: Center(child: _widgetOptions.elementAt(focusedPage)),
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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              offset: Offset(0, -3),
            )
          ]
        ),
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
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // const HomeScreen({Key? key}) : super(key: key);
//   // static const List<Color> lineColor = [
//   //   Color(0xffffffff),
//   // ];
class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  var _isLoading = true;
  List<Reminder> reminders = [];

  @override
  void initState() {
    if (_isLoading) {
      user = auth.currentUser;
      super.initState();
      AwesomeNotifications().isNotificationAllowed().then(
        (isAllowed) {
          if (!isAllowed) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Allow Notifications'),
                content:
                    const Text('Our app would like to send you notifications'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Don\'t Allow',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () => AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Navigator.pop(context)),
                    child: const Text(
                      'Allow',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
      firestore
          .collection('users')
          .doc(user?.uid)
          .collection('reminders')
          .orderBy('timestamp', descending: true)
          .get()
          .then((rems) {
        for (var rem in rems.docs) {
          var r = rem.data();
          // debugPrint("Id: ${r['id']}");
          // debugPrint("Id type: ${r['id'].runtimeType}");
          // debugPrint("Doc Id type: ${rem.id.runtimeType}");
          // debugPrint("Hour Id type: ${r['hour'].runtimeType}");
          // debugPrint("Minute Id type: ${r['minute'].runtimeType}");
          reminders.add(Reminder(
            rem.id,
            r['id'],
            r['type'],
            r['body'],
            r['year'],
            r['month'],
            r['day'],
            r['weekday'],
            r['hour'],
            r['minute'],
          ));
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    AwesomeNotifications().createdSink.close();
    super.dispose();
  }

  // Future<void> addWeeklyReminder(
  //     String body, int weekday, int hour, int minute) async {
  //   await firestore
  //       .collection('users')
  //       .doc(user?.uid)
  //       .collection('reminders')
  //       .add({
  //     'user': user?.uid,
  //     'id': createUniqueId(),
  //     'body': body,
  //     'weekday': weekday,
  //     'hour': hour,
  //     'minute': minute,
  //     'type': 'weekly'
  //   });
  // }

  // Future<void> addDailyReminder(String body, int hour, int minute) async {
  //   await firestore
  //       .collection('users')
  //       .doc(user?.uid)
  //       .collection('reminders')
  //       .add({
  //     'user': user?.uid,
  //     'id': createUniqueId(),
  //     'body': body,
  //     'hour': hour,
  //     'minute': minute,
  //     'type': 'daily'
  //   });
  // }

  // Future<void> addHourlyReminder(String body, int hour) async {
  //   await firestore
  //       .collection('users')
  //       .doc(user?.uid)
  //       .collection('reminders')
  //       .add({
  //     'user': user?.uid,
  //     'id': createUniqueId(),
  //     'body': body,
  //     'hour': hour,
  //     'type': 'hourly'
  //   });
  // }

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
      body: Container(
        child: SafeArea(
          child: Text("Home Page"),
        ),
      ),
    );
  }
}

// List<PieChartSectionData> data = [
//   PieChartSectionData(title: 'A', color: Colors.red),
//   PieChartSectionData(title: 'B', color: Colors.yellow),
//   PieChartSectionData(title: 'C', color: Colors.green),
//   PieChartSectionData(title: 'D', color: Colors.blue),
// ];

// class LineTitles {
//   static getTitleData() => FlTitlesData(
//     show: true,
//     topTitles: SideTitles(
//       showTitles: false),
//     bottomTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 0:
//             return 'MON';
//           case 1:
//             return 'TUE';
//           case 2:
//             return 'WED';
//           case 3:
//             return 'THUR';
//           case 4:
//             return 'FRI';
//           case 5:
//             return 'SAT';
//           case 6:
//             return 'SUN';
//         }
//         return '';
//       },
//       margin: 8,
//     ),
//     leftTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 4:
//             return '25';
//           case 9:
//             return '50';
//           case 14:
//             return '75';
//           case 19:
//             return '100';
//         }
//         return '';
//       },
//     ),
//     rightTitles: SideTitles(
//       showTitles: false,
//     )
//   );
// }