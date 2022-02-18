import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../widgets/notification_utils.dart';
import '../widgets/new_reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: SpeedDial(
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
                children: reminders.map((rem) {
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
              ),
            ),
    );
  }
}
