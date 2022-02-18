import 'package:flutter/material.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './notification_utils.dart';

class NewReminder extends StatefulWidget {
  final String type;

  const NewReminder(this.type, {Key? key}) : super(key: key);

  @override
  _NewReminderState createState() => _NewReminderState();
}

class _NewReminderState extends State<NewReminder> {
  final titleController = TextEditingController();
  NotificationWeekAndTime? pickedSchedule;
  TimeOfDay? pickedTime;
  int? pickedHours;
  DateTime? pickedDateTime;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  var rem;

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
  }

  Future<void> addReminder(String body, int? year, int? month, int? day,
      int? hour, int? minute, int id) async {
    var value = await firestore
        .collection('users')
        .doc(user?.uid)
        .collection('reminders')
        .add({
      'user': user?.uid,
      'id': id,
      'body': body,
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'type': 'once',
      'timestamp': DateTime.now()
    });
    rem = Reminder(
        value.id, id, 'once', body, year, month, day, null, hour, minute);
  }

  Future<void> addWeeklyReminder(
      String body, int? weekday, int? hour, int? minute, int id) async {
    var value = await firestore
        .collection('users')
        .doc(user?.uid)
        .collection('reminders')
        .add({
      'user': user?.uid,
      'id': id,
      'body': body,
      'weekday': weekday,
      'hour': hour,
      'minute': minute,
      'type': 'weekly',
      'timestamp': DateTime.now()
    });
    rem = Reminder(
        value.id, id, 'weekly', body, null, null, null, weekday, hour, minute);
  }

  Future<void> addDailyReminder(
      String body, int? hour, int? minute, int id) async {
    var value = await firestore
        .collection('users')
        .doc(user?.uid)
        .collection('reminders')
        .add({
      'user': user?.uid,
      'id': id,
      'body': body,
      'hour': hour,
      'minute': minute,
      'type': 'daily',
      'timestamp': DateTime.now()
    });
    rem = Reminder(
        value.id, id, 'daily', body, null, null, null, null, hour, minute);
  }

  Future<void> addHourlyReminder(String body, int? hour, int id) async {
    var value = await firestore
        .collection('users')
        .doc(user?.uid)
        .collection('reminders')
        .add({
      'user': user?.uid,
      'id': id,
      'body': body,
      'hour': hour,
      'type': 'hourly',
      'timestamp': DateTime.now()
    });
    rem = Reminder(
        value.id, id, 'hourly', body, null, null, null, null, hour, null);
  }

  void _submitData() async {
    final enteredData = titleController.text;
    if (enteredData.isEmpty ||
        (pickedSchedule == null &&
            pickedTime == null &&
            pickedHours == null &&
            pickedDateTime == null)) {
      return;
    }
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();
    debugPrint('Timezone $localTimeZone');
    int id = createUniqueId();
    if (widget.type == 'once') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'basic_channel',
            title: 'Reminder',
            body: enteredData,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.BigText),
        schedule: NotificationCalendar(
          year: pickedDateTime?.year,
          month: pickedDateTime?.month,
          day: pickedDateTime?.day,
          hour: pickedDateTime?.hour,
          minute: pickedDateTime?.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
        ),
      );
      await addReminder(
          enteredData,
          pickedDateTime?.year,
          pickedDateTime?.month,
          pickedDateTime?.day,
          pickedDateTime?.hour,
          pickedDateTime?.minute,
          id);
    } else if (widget.type == 'weekly') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'scheduled_channel',
            title: 'Weekly Reminder',
            body: enteredData,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.BigText),
        schedule: NotificationCalendar(
          weekday: pickedSchedule?.dayOfTheWeek,
          hour: pickedSchedule?.timeOfDay.hour,
          minute: pickedSchedule?.timeOfDay.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
        ),
      );
      await addWeeklyReminder(enteredData, pickedSchedule?.dayOfTheWeek,
          pickedSchedule?.timeOfDay.hour, pickedSchedule?.timeOfDay.minute, id);
    } else if (widget.type == 'daily') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'scheduled_channel',
            title: 'Daily Reminder',
            body: enteredData,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.BigText),
        schedule: NotificationCalendar(
            hour: pickedTime?.hour,
            minute: pickedTime?.minute,
            second: 0,
            millisecond: 0,
            repeats: true,
            allowWhileIdle: true),
      );
      await addDailyReminder(
          enteredData, pickedTime?.hour, pickedTime?.minute, id);
    } else {
      int intervalTime = pickedHours! * 60 * 60;
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: 'scheduled_channel',
            title: '$pickedHours Hourly Reminder',
            body: enteredData,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.BigText),
        schedule: NotificationInterval(
            interval: intervalTime, repeats: true, allowWhileIdle: true),
      );
      await addHourlyReminder(enteredData, pickedHours, id);
    }
    Navigator.of(context).pop(rem);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Reminder'),
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                onSubmitted: (_) => _submitData(),
              ),
              Container(
                height: 70,
                child: Row(
                  children: <Widget>[
                    if (widget.type == 'once') ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Choose date and time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          pickedDateTime = await pickDateTime(context);
                        },
                      ),
                    ] else if (widget.type == 'weekly') ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Choose schedule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          pickedSchedule = await pickSchedule(context);
                        },
                      ),
                    ] else if (widget.type == 'daily') ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Choose time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          pickedTime = await pickTime(context);
                        },
                      ),
                    ] else
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Choose interval in hours',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          void pickHours(int hours) {
                            pickedHours = hours;
                          }

                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => IntegerExample(pickHours)));
                          debugPrint('Picked hours: $pickedHours');
                        },
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                child: const Text('Add Reminder'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: _submitData,
              )
            ],
          ),
        ),
      ),
    );
  }
}
