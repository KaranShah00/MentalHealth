import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/auth_form.dart';
import 'dart:math' as math;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  final List<Variable> defaultVariables = [
    Variable("Water", "Cups", 8, 0, "#05b1d8"),
    Variable("Coffee", "Cups", 4, 0, "#613204"),
    Variable("Exercise", "Minutes", 60, 0, "#11c808"),
    Variable("Meditation", "Minutes", 30, 0, "#b6b903"),
    Variable("Rest", "Hours", 8, 0, "#681bb6"),
  ];

  void _submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .set({
              'username': username,
              'email': email
            });
        
        for (int i = 0;i < 5; i++) {
          await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .collection('variables')
            .doc(defaultVariables[i].name)
            .set({
              'name': defaultVariables[i].name,
              'unit': defaultVariables[i].unit,
              'target': defaultVariables[i].target,
              'achieved': defaultVariables[i].achieved,
              'color': defaultVariables[i].color,
              // 'data': List<Data>.generate(365, (i) =>  Data(
              //             DateTime.utc(
              //               DateTime.now().year,
              //               DateTime.now().month,
              //               DateTime.now().day,
              //             ).subtract(Duration(days: i)), (math.Random().nextInt(20))
              //           )
              //         ),
            });

            for (int j = 0; j < 30; j++) {
              await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user?.uid)
              .collection('variables')
              .doc(defaultVariables[i].name)
              .collection('data')
              .doc()
              .set({
                'date': DateTime.utc(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ).subtract(Duration(days: j)),
                'score': (math.Random().nextInt(20)),
              });
            }

            await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .collection('variables')
            .doc(defaultVariables[i].name)
            .set({
              'name': defaultVariables[i].name,
              'unit': defaultVariables[i].unit,
              'target': defaultVariables[i].target,
              'achieved': defaultVariables[i].achieved,
              'color': defaultVariables[i].color,
              // 'data': List<Data>.generate(365, (i) =>  Data(
              //             DateTime.utc(
              //               DateTime.now().year,
              //               DateTime.now().month,
              //               DateTime.now().day,
              //             ).subtract(Duration(days: i)), (math.Random().nextInt(20))
              //           )
              //         ),
            });
        }
      }
    } catch (error) {
      debugPrint("Hi");
      var message = 'An error occurred, please check your credentials';
      if (error.toString() != null) {
        message = error.toString();
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}

class Variable {
  String name;
  String unit;
  int target;
  int achieved;
  String color;
  List<Data>? data;

  Variable(this.name, this.unit, this.target, this.achieved, this.color);
  int getColor() {
    String formattedHex =  "FF" + color.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
}

class Data {
  DateTime date;
  int score;
  Data(this.date, this.score);
}