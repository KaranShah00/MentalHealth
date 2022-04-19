import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/myaudio.dart';
import 'package:mental_health/screens/exercise_screen.dart';
import 'package:mental_health/screens/facial_detection_screen.dart';
import 'package:mental_health/screens/profile_screen.dart';
import 'package:mental_health/screens/stats_screen.dart';
import 'package:mental_health/screens/reminders_screen.dart';
import 'package:mental_health/screens/help_screen.dart';
import './music_screen.dart';
import './home_screen.dart';
import './exercise_screen.dart';
import './depression_questionnaire_screen.dart';
import './journal_screen.dart';
import './questionnaire_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final String mood;
  const RecommendationScreen(this.mood, {Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  var data;
  bool trackDataValue = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late String name = "";
  FirebaseStorage? storage;
  Reference? ref;
  var _isLoading = false;

  Map<String, List<Color>> color = {
    'red': [Color.fromARGB(255, 255, 111, 0),Color.fromARGB(255, 220, 23, 23),],
    'blue': [Color.fromARGB(255, 68, 175, 231),Color.fromARGB(255, 13, 42, 79)],
    'green': [Color.fromARGB(255, 115, 202, 0), Color.fromARGB(255, 20, 147, 3),],
    'yellow': [Color.fromARGB(255, 255, 217, 59),Color.fromARGB(255, 255, 186, 0),],
  };

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    data = firestore.collection('users').doc(user?.uid);
    storage = FirebaseStorage.instance;
    ref = storage!.ref('/${widget.mood}');
    data.get().then((value) {
      setState(() {
        name = value.data()!['username'];
        trackDataValue = value.data()!['track'];
        // _isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    print(widget.mood);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xff81dc17),
        title: Text('Mental Wellness'),
        actions: [
          TextButton(
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 115, 202, 0),
                  Color.fromARGB(255, 20, 147, 3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 100,
            width: 450,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), //color of shadow
                  spreadRadius: 5, //spread radius
                  blurRadius: 7, // blur radius
                  offset: Offset(0, 2),
                )
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color.fromARGB(255, 175, 250, 0),Color.fromARGB(255, 50, 182, 3)]
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Relax  •  Engage  •  Unwind",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 20,
                      // color: Colors.black,
                    ),
                  ),
                  Text(
                    "We've got some great recommendations for you",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      // letterSpacing: 3,
                      fontSize: 15,
                      // color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: card("Music", color['blue'], Icon(Icons.music_note, color: Colors.white, size: 40,)),
                  onTap:() async{
                    if(!_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });
                    }
                    ListResult result = await ref!.listAll();
                    List<Map<String, String>> data = [];
                    for (Reference r in result.items) {
                      data.add({
                        'url': await r.getDownloadURL(),
                        'name': r.name,
                        'image':
                            'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
                      });
                    }
                    Provider.of<MyAudio>(context, listen: false).addData(data);
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MusicScreen('Music');
                    }),
                  );
                  }
                ),
                GestureDetector(
                  child: card("Meditation", color['green'], Icon(Icons.man, color: Colors.white, size: 40,)),
                  onTap:() async{
                    if(!_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });
                    }
                    ref = storage!.ref('/meditation');
                    ListResult result = await ref!.listAll();
                    debugPrint("l: ${result.items.length}");
                    List<Map<String, String>> data = [];
                    for (Reference r in result.items) {
                      data.add({
                        'url': await r.getDownloadURL(),
                        'name': r.name,
                        'image':
                            'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
                      });
                    }
                    Provider.of<MyAudio>(context, listen: false).addData(data);
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MusicScreen('Meditation');
                    }),
                  );
                  }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  child: card("Exercises", color['red'], Icon(Icons.directions_walk_sharp, color: Colors.white, size: 40,)),
                  onTap:() => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ExerciseScreen(widget.mood);
                    }),
                  )
                ),
                // GestureDetector(
                //   child: card("Facial Detection", color['yellow']),
                //   onTap:() => Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) {
                //       return FacialDetectionScreen();
                //     }),
                //   )
                // ),
              ],
            ),
          ),
          // ElevatedButton(
          //   onPressed: () => Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (ctx) => MusicScreen(),
          //     ),
          //   ),
          //   child: Text('Music'),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) {
          //                 return ExerciseScreen();
          //               }
          //             ),
          //           );
          //         },
          //   child: Text('Exercise'),
          // ),
        ],
      ),
    );
  }

  Widget card(String title, List<Color>? color, Icon icon) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        height: 120,
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), //color of shadow
              spreadRadius: 5, //spread radius
              blurRadius: 7, // blur radius
              offset: Offset(0, 2),
            )
          ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: color!
            ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 10,),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                // letterSpacing: 3,
                fontSize: 18,
                // shadows: [
                //   Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 5)
                // ],
                color: Colors.white,
              ),
            ),
          ],
        )),
    );
  }
}