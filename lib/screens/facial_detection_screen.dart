import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mental_health/screens/recommendation_screen.dart';

class FacialDetectionScreen extends StatefulWidget {
  const FacialDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FacialDetectionScreen> createState() => _FacialDetectionScreenState();
}

class _FacialDetectionScreenState extends State<FacialDetectionScreen> {
  // var text = 'Not ready';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  File? selectedImage;
  String? message = '';
  String? value = '';
  String dominantEmotion = '';
  var imageHeight;
  var imageWidth;
  var mood;
  var flag = false;

  uploadImage() async {
    setState(() {});
    if(selectedImage != null) {
      flag = false;
      dominantEmotion = "Analyzing...";
      final request = http.MultipartRequest(
          "POST", Uri.parse('http://192.168.29.157:5000/upload'));
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
        var emotions = result['emotion'] as Map;//Map
        mood = result['dominant_emotion'];
        debugPrint(mood);
        debugPrint(emotions.toString());
        double score = 0;
        emotions.forEach((key, value) {
          if(key != "disgust" && key != "neutral" && key != "surprise") {
            if(value > score) {
              score = value;
              mood = key;
            }
          }
        });
        dominantEmotion = "You are feeling " + mood;
        flag = true;
        firestore.collection('users').doc(user?.uid).collection('variables').doc('Mood').collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': score/100, 'target': 1}, SetOptions(merge: true));
        debugPrint("Emotion: $dominantEmotion");
        setState(() {});
      } catch(e) {
        debugPrint('The provided photo could not be analysed');
        dominantEmotion = "Could not detect face. Please upload another image.";
        setState(() {});
      }
    }
  }

  uploadText() async {
    var response = await http.post(Uri.parse('http://192.168.29.157:5000/text'),
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
      var decodedImage = await decodeImageFromList(selectedImage!.readAsBytesSync());
      print(decodedImage.width);
      print(decodedImage.height);
      imageWidth = decodedImage.width/15;
      imageHeight = decodedImage.height/15;
      setState(() {});
    }
  }

  Future getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      var decodedImage = await decodeImageFromList(selectedImage!.readAsBytesSync());
      print(decodedImage.width);
      print(decodedImage.height);
      imageWidth = decodedImage.width/15;
      imageHeight = decodedImage.height/15;
      setState(() {});
    }
  }

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color(0xff8000ff),
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
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 108, 0, 250),
                  Color.fromARGB(255, 51, 5, 119)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SpeedDial(
        backgroundColor: Color.fromARGB(255, 84, 1, 193),
        animatedIcon: AnimatedIcons.add_event,
        overlayOpacity: 0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_a_photo),
            label: "Take a photo",
            onTap: getImageFromCamera
          ),
          SpeedDialChild(
            child: const Icon(Icons.photo),
            label: "Upload from gallery",
            onTap: getImageFromGallery
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              selectedImage == null
                  ? const Text('Please pick an image to upload')
                  : Container(
                    width: double.parse(imageWidth.toString()),
                    height: double.parse(imageHeight.toString()),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10
                      )
                      ]
                    ),
                      child: Image.file(selectedImage!)
                    ),
                  selectedImage == null ? const Text("") : TextButton.icon(
                  onPressed: uploadImage,
                  icon: const Icon(Icons.upload_rounded, color: Color(0xff8000ff),),
                  label: const Text(
                    'Upload',
                    style: TextStyle(
                      color: Color(0xff8000ff),
                    )
                  )
              ),
              Text(dominantEmotion),
              flag == false ? Container() : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 84, 1, 193),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23)
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RecommendationScreen(mood);
                    }),
                  );
                },
                child: Text("Go to Recommendations")
              )
            ],
          ),
        ),
      ),
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
