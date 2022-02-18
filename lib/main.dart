import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import './screens/auth_screen.dart';
import './screens/home_screen.dart';
import './screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mental Well Being',
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (ctx, userSnapshot){
        if(userSnapshot.connectionState == ConnectionState.waiting){
          return LoadingScreen();
        }
        if(userSnapshot.hasData){
          return MyNavigationBar();
        }
        return AuthScreen();
      },),
    );
  }
}