import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import './reminder_screen.dart';
import '../widgets/notification_utils.dart';
import '../widgets/new_reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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
        title: const Text('Mental Well Being'),
        actions: [
          TextButton(
              child: const Text('Reminders'),
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (bCtx) => const ReminderScreen()));
              }),
          TextButton(
              child: const Text('Logout'),
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  TextButton(
                    child: const Text('Normal Notify'),
                    onPressed: () async {
                      await AwesomeNotifications().createNotification(
                          content: NotificationContent(
                              id: 11,
                              channelKey: 'basic_channel',
                              title: 'Simple Notification',
                              body: 'Simple body'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder created'),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('Schedule Notify with Repeat'),
                    onPressed: () async {
                      String localTimeZone = await AwesomeNotifications()
                          .getLocalTimeZoneIdentifier();
                      debugPrint('Timezone $localTimeZone');
                      await AwesomeNotifications().createNotification(
                          content: NotificationContent(
                            id: 12,
                            channelKey: 'scheduled_channel',
                            title: 'Notification at every single minute',
                            body:
                                'This notification was schedule to repeat at every single minute.',
                          ),
                          schedule: NotificationInterval(
                              interval: 60,
                              timeZone: localTimeZone,
                              repeats: true));
                    },
                  ),
                  TextButton(
                      child: const Text('Reminder'),
                      onPressed: () async {
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
                      }),
                  TextButton(
                      child: const Text('Weekly Reminder'),
                      onPressed: () async {
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
                      }),
                  TextButton(
                      child: const Text('Daily Reminder'),
                      onPressed: () async {
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
                      }),
                  TextButton(
                      child: const Text('Hourly Reminder'),
                      onPressed: () async {
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
                      }),
                  // TextButton(
                  //   child: const Text('Weekly Reminder'),
                  //   onPressed: () async {
                  //     NotificationWeekAndTime? pickedSchedule =
                  //         await pickSchedule(context);
                  //     if (pickedSchedule != null) {
                  //       String localTimeZone =
                  //           await AwesomeNotifications().getLocalTimeZoneIdentifier();
                  //       debugPrint('Timezone $localTimeZone');
                  //       await AwesomeNotifications().createNotification(
                  //         content: NotificationContent(
                  //           id: 15,
                  //           channelKey: 'scheduled_channel',
                  //           title: 'Weekly Notification with Calendar',
                  //           body:
                  //               'This notification was schedule with calendar for every week repeats.',
                  //         ),
                  //         schedule: NotificationCalendar(
                  //             weekday: pickedSchedule.dayOfTheWeek,
                  //             hour: pickedSchedule.timeOfDay.hour,
                  //             minute: pickedSchedule.timeOfDay.minute,
                  //             second: 0,
                  //             millisecond: 0,
                  //             repeats: true),
                  //       );
                  //       await addWeeklyReminder(
                  //         'test',
                  //         pickedSchedule.dayOfTheWeek,
                  //         pickedSchedule.timeOfDay.hour,
                  //         pickedSchedule.timeOfDay.minute,
                  //       );
                  //     }
                  //   },
                  // ),
                  // TextButton(
                  //   child: const Text('Daily Reminder'),
                  //   onPressed: () async {
                  //     TimeOfDay? pickedTime = await pickTime(context);
                  //     if (pickedTime != null) {
                  //       String localTimeZone =
                  //           await AwesomeNotifications().getLocalTimeZoneIdentifier();
                  //       debugPrint('Timezone $localTimeZone');
                  //       await AwesomeNotifications().createNotification(
                  //         content: NotificationContent(
                  //           id: 16,
                  //           channelKey: 'scheduled_channel',
                  //           title: 'Daily Notification with Calendar',
                  //           body:
                  //               'This notification was schedule with calendar for daily repeats.',
                  //         ),
                  //         schedule: NotificationCalendar(
                  //             hour: pickedTime.hour,
                  //             minute: pickedTime.minute,
                  //             second: 0,
                  //             millisecond: 0,
                  //             repeats: true),
                  //       );
                  //       await addDailyReminder(
                  //           'test', pickedTime.hour, pickedTime.minute);
                  //     }
                  //   },
                  // ),
                  // TextButton(
                  //   child: const Text('Hourly Reminder'),
                  //   onPressed: () async {
                  //     int? pickedHours;
                  //     void pickHours(int hours) {
                  //       pickedHours = hours;
                  //     }
                  //
                  //     await Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (ctx) => IntegerExample(pickHours)));
                  //     debugPrint('Picked hours: $pickedHours');
                  //     if (pickedHours != null) {
                  //       String localTimeZone =
                  //           await AwesomeNotifications().getLocalTimeZoneIdentifier();
                  //       debugPrint('Timezone $localTimeZone');
                  //       int intervalTime = pickedHours! * 60 * 60;
                  //       debugPrint("Entering");
                  //       await AwesomeNotifications().createNotification(
                  //           content: NotificationContent(
                  //             id: 17,
                  //             channelKey: 'scheduled_channel',
                  //             title: 'Hourly Notification with Calendar',
                  //             body:
                  //                 'This notification was schedule with calendar for hourly repeats.',
                  //           ),
                  //           schedule: NotificationInterval(
                  //               interval: intervalTime, repeats: true));
                  //       await addHourlyReminder('test', pickedHours!);
                  //     }
                  //   },
                  // ),
                  TextButton(
                    onPressed: () async {
                      await AwesomeNotifications().cancelSchedule(12);
                    },
                    child: const Text('Cancel Schedule 12'),
                  ),
                  TextButton(
                    onPressed: () async {
                      debugPrint('Listing Schedules');
                      List<NotificationModel> activeSchedules =
                          await AwesomeNotifications()
                              .listScheduledNotifications();
                      for (NotificationModel schedule in activeSchedules) {
                        debugPrint('pending notification: ['
                            'id: ${schedule.content!.id}, '
                            'title: ${schedule.content!.titleWithoutHtml}, '
                            'schedule: ${schedule.schedule.toString()}'
                            ']');
                      }
                    },
                    child: const Text('List All schedules'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await AwesomeNotifications().cancelAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cancelled all reminders'),
                        ),
                      );
                    },
                    child: const Text('Cancel all schedules'),
                  ),
                  ...reminders.map((rem) {
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: Text(rem.type),
                        title: Text(rem.body),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            setState(() {
                              reminders.removeWhere(
                                  (element) => element.id == rem.id);
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
                  })
                ],
              ),
            ),
    );
  }
}
