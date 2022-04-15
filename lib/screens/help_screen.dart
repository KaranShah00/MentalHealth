import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // var text = 'Not ready';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff8000ff),
        title: const Text('Mental Wellness'),
        actions: [
          TextButton(
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: Container(
        child: Text("Help Screen"),
      )
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     FloatingActionButton(
      //       child: const Icon(Icons.add_a_photo),
      //       onPressed: getImageFromCamera,
      //     ),
      //     FloatingActionButton(
      //       child: const Icon(Icons.photo),
      //       onPressed: getImageFromGallery,
      //     ),
      //   ],
      // ),
    );
  }
}
