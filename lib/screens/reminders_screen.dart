import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../widgets/notification_utils.dart';
import '../widgets/new_reminder.dart';


class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  @override
  int range = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late TabController _tabController;
  var _isLoading = true;
  List<Reminder> reminders = [];
  List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
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

  Widget displaySubtitle(Reminder rem) {
    if(rem.type == 'weekly') {
      return Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 5,),
          Text(weekdays[rem.weekday! + 1]),
          const SizedBox(width: 20,),
          const Icon(Icons.watch_later),
          const SizedBox(width: 5,),
          Text('${rem.hour.toString().padLeft(2, '0')}:${rem.minute.toString().padLeft(2, '0')}')
        ],
      );
    }
    else if(rem.type == 'daily') {
      return Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 5,),
          const Text('Daily'),
          const SizedBox(width: 20,),
          const Icon(Icons.watch_later),
          const SizedBox(width: 5,),
          Text('${rem.hour.toString().padLeft(2, '0')}:${rem.minute.toString().padLeft(2, '0')}')
        ],
      );
    }
    else if(rem.type == 'hourly') {
      return Row(
        children: [
          const Icon(Icons.watch_later),
          const SizedBox(width: 5,),
          rem.hour == 1 ? Text('Every ${rem.hour} hour') : Text('Every ${rem.hour} hours')
        ],
      );
    }
    else{
      return Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 5,),
          Text('${rem.day}/${rem.month}/${rem.year}'),
          const SizedBox(width: 20,),
          const Icon(Icons.watch_later),
          const SizedBox(width: 5,),
          Text('${rem.hour.toString().padLeft(2, '0')}:${rem.minute.toString().padLeft(2, '0')}')
        ],
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      range = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffec407a),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SpeedDial(
        backgroundColor: Color(0xffec407a),
        animatedIcon: AnimatedIcons.add_event,
        overlayOpacity: 0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.calendar_today_rounded),
            label: "Custom Reminder",
            onTap: () async {
              var value;
              value = await showModalBottomSheet(
                  context: context,
                  builder: (bCtx) => const NewReminder('once'));
              if (value != null) {
                setState(() {
                  reminders.insert(0, value);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder created'),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.watch_later),
            label: "Hourly Reminder",
            onTap: () async {
              var value;
              value = await showModalBottomSheet(
                  context: context,
                  builder: (bCtx) => const NewReminder('hourly'));
              if (value != null) {
                setState(() {
                  reminders.insert(0, value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder created'),
                    ),
                  );
                });
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.calendar_view_day),
            label: "Daily Reminder",
            onTap: () async {
              var value;
              value = await showModalBottomSheet(
                  context: context,
                  builder: (bCtx) => const NewReminder('daily'));
              if (value != null) {
                setState(() {
                  reminders.insert(0, value);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder created'),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.calendar_view_week),
            label: "Weekly Reminder",
            onTap: () async {
              var value;
              value = await showModalBottomSheet(
                  context: context,
                  builder: (bCtx) => const NewReminder('weekly'));
              if (value != null) {
                setState(() {
                  reminders.insert(0, value);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder created'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[...reminders.map((rem) {
            return Card(
              elevation: 5,
              child: ListTile(
                title: Text(rem.body),
                subtitle: displaySubtitle(rem),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    setState(() {
                      reminders
                          .removeWhere((element) => element.id == rem.id);
                    });
                    await firestore
                        .collection('users')
                        .doc(user?.uid)
                        .collection('reminders')
                        .doc(rem.docId)
                        .delete();
                    await AwesomeNotifications().cancelSchedule(rem.id);
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminder deleted'),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
            const SizedBox(height: 70,),
          ],
        ),
      ),
    );
  }
}

// class LineTilesWeek {
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

// class LineTilesMonth {
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
//             return 'JAN';
//           // case 1:
//           //   return 'FEB';
//           case 2:
//             return 'MAR';
//           // case 3:
//           //   return 'APR';
//           case 4:
//             return 'MAY';
//           // case 5:
//           //   return 'JUN';
//           case 6:
//             return 'JUL';
//           // case 7:
//           //   return 'AUG';
//           case 8:
//             return 'SEP';
//           // case 9:
//           //   return 'OCT';
//           case 10:
//             return 'NOV';
//           // case 11:
//           //   return 'DEC';
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