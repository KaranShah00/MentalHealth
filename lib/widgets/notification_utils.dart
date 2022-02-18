import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

class Reminder {
  final String docId;
  final int id;
  final String type;
  final String body;
  final int? year;
  final int? month;
  final int? day;
  final int? weekday;
  final int? hour;
  final int? minute;

  Reminder(this.docId, this.id, this.type, this.body, this.year, this.month,
      this.day, this.weekday, this.hour, this.minute);
}

class NotificationWeekAndTime {
  final int dayOfTheWeek;
  final TimeOfDay timeOfDay;

  NotificationWeekAndTime({
    required this.dayOfTheWeek,
    required this.timeOfDay,
  });
}

Future<TimeOfDay?> pickTime(BuildContext context) async {
  TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(
          const Duration(minutes: 1),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      });
  return timeOfDay;
}

Future<NotificationWeekAndTime?> pickSchedule(
  BuildContext context,
) async {
  List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  TimeOfDay? timeOfDay;
  int? selectedDay;

  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'I want to be reminded every:',
            textAlign: TextAlign.center,
          ),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 3,
            children: [
              for (int index = 0; index < weekdays.length; index++)
                ElevatedButton(
                  onPressed: () {
                    selectedDay = index + 1;
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.blue,
                    ),
                  ),
                  child: Text(weekdays[index]),
                ),
            ],
          ),
        );
      });

  if (selectedDay != null) {
    timeOfDay = await pickTime(context);
    debugPrint("time: $timeOfDay");
    if (timeOfDay != null) {
      return NotificationWeekAndTime(
          dayOfTheWeek: selectedDay!, timeOfDay: timeOfDay);
    }
  }
  return null;
}

Future<DateTime?> pickDateTime(BuildContext context) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    TimeOfDay? timeOfDay = await pickTime(context);
    if (timeOfDay != null) {
      DateTime selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, timeOfDay.hour, timeOfDay.minute);
      return selectedDateTime;
    }
  }
  return null;
}

class IntegerExample extends StatefulWidget {
  final Function pickHours;

  IntegerExample(this.pickHours);

  @override
  _IntegerExampleState createState() => _IntegerExampleState();
}

class _IntegerExampleState extends State<IntegerExample> {
  int _currentValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick hours'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              NumberPicker(
                  value: _currentValue,
                  minValue: 1,
                  maxValue: 23,
                  step: 1,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              _currentValue == 1
                  ? Text(
                      'Interval: $_currentValue hour',
                      style: const TextStyle(fontSize: 20),
                    )
                  : Text(
                      'Interval: $_currentValue hours',
                      style: const TextStyle(fontSize: 20),
                    ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  widget.pickHours(_currentValue);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
