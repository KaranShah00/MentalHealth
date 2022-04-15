import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import './screens/auth_screen.dart';
import './screens/home_screen.dart';
import './screens/loading_screen.dart';
import './model/myaudio.dart';

void printHello() async{
debugPrint("hello there");
List<String> quotes = [
  "You don’t have to control your thoughts. You just have to stop letting them control you",
  "Take your time healing, as long as you want. Nobody else knows what you’ve been through. How could they know how long it will take to heal you?",
  "One small crack does not mean that you are broken, it means that you were put to the test and you didn’t fall apart",
  "Out of suffering have emerged the strongest souls; the most massive characters are seared with scars",
  "Recovery is not one and done. It is a lifelong journey that takes place one day, one step at a time",
  "Let your story go. Allow yourself to be present with who you are right now",
  "You can’t control everything. Sometimes you just need to relax and have faith that things will work out. Let go a little and just let life happen",
  "Happiness can be found even in the darkest of times, if one only remembers to turn on the light",
  "You, yourself, as much as anybody in the entire universe, deserve your love and affection",
  "Self-care is how you take your power back",
];
await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: 'basic_channel',
            title: 'Daily Motivation',
            body: (quotes..shuffle()).first,
            notificationLayout: NotificationLayout.BigText),
      );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
            channelKey: 'scheduled_channel',
            channelName: 'Scheduled Notifications',
            channelDescription: 'Notification channel for scheduled tests',
            defaultColor: Colors.teal,
            importance: NotificationImportance.High,
            channelShowBadge: true),
      ],
      debug: true);
  // int i = 0;
  // const duration = Duration(seconds: 10);
  // Timer.periodic(duration, (timer) async {
  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //         id: 1,
  //         channelKey: 'basic_channel',
  //         title: 'Daily Motivation',
  //         body: (quotes..shuffle()).first,
  //         notificationLayout: NotificationLayout.BigText),
  //   );
  //   i += 1;
  //   if (i == 3) {
  //     timer.cancel();
  //   }
  // });
  runApp(MyApp());
  final int helloAlarmID = 0;
  await AndroidAlarmManager.periodic(const Duration(days: 1), helloAlarmID, printHello, exact: true, allowWhileIdle: true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mental Well Being',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          }
          if (userSnapshot.hasData) {
            return ChangeNotifierProvider(
                create: (_) => MyAudio(), child: MyNavigationBar());
          }
          return AuthScreen();
        },
      ),
    );
  }
}
