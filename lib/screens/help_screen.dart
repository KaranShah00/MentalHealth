import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // var text = 'Not ready';
  File? selectedImage;
  String? message = '';
  String? value = '';

  uploadImage() async {
    if(selectedImage != null) {
      final request = http.MultipartRequest(
          "POST", Uri.parse('http://192.168.29.12:5000/upload'));
      //http.MultipartRequest("POST", Uri.parse('http://10.0.2.2:5000/upload'));
      final headers = {"Content-type": "multipart/form-data"};
      request.files.add(http.MultipartFile('image',
          selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
          filename: selectedImage!
              .path
              .split("/")
              .last));
      request.headers.addAll(headers);
      final response = await request.send();
      http.Response res = await http.Response.fromStream(response);
      try {
        final resJson = jsonDecode(res.body);
        message = resJson['message'];
        var result = resJson['result'];
        var emotions = result['emotion']; //Map
        var dominant = result['dominant_emotion'];
        debugPrint(dominant);
        setState(() {});
      } catch(e) {
        debugPrint('The provided photo could not be analysed');
      }
    }
  }

  uploadText() async {
    var response = await http.post(Uri.parse('http://192.168.29.12:5000/text'),
        body: {"message": value});
    // var response = await http.post(Uri.parse('http://172.16.31.37:5000/text'),
    //     body: {"message": value});
    var result = response.body;
    debugPrint(response.body);
    debugPrint(jsonDecode(result)['Angry'].toString());
    setState(() {});
  }

  Future getImageFromCamera() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      setState(() {});
    }
  }

  Future getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      setState(() {});
    }
  }

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // TextButton(
            //   child: Text(text),
            //   onPressed: () async {
            //     http.Response response =
            //         await http.get(Uri.parse('http://192.168.29.12:5000/'));
            //     //await http.get(Uri.parse('http://10.0.2.2:5000/'));
            //     var data = response.body;
            //     text = jsonDecode(data)['message'];
            //     setState(() {});
            //   },
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter the text to be analysed',
                ),
                onChanged: (val) => value = val,
              ),
            ),
            TextButton(child: const Text('Submit'), onPressed: uploadText),
            selectedImage == null
                ? const Text('Please pick an image to upload')
                : Expanded(child: Image.file(selectedImage!)),
            TextButton.icon(
                onPressed: uploadImage,
                icon: const Icon(Icons.upload),
                label: const Text('Upload'))
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add_a_photo),
            onPressed: getImageFromCamera,
          ),
          FloatingActionButton(
            child: const Icon(Icons.photo),
            onPressed: getImageFromGallery,
          ),
        ],
      ),
    );
  }
}
