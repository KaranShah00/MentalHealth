import 'dart:math';
import 'dart:async';

// import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_health/screens/profile_screen.dart';
import 'package:mental_health/screens/stats_screen.dart';
import 'package:mental_health/screens/reminders_screen.dart';
import 'package:mental_health/screens/help_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../widgets/notification_utils.dart';
import '../widgets/new_reminder.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // const HomeScreen({Key? key}) : super(key: key);
//   // static const List<Color> lineColor = [
//   //   Color(0xffffffff),
//   // ];
class _ExerciseScreenState extends State<ExerciseScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  var _isLoading = true;
  var random = new Random();
  int exercise_number = 0;
  String mood = 'angry';
  Timer? timer;
  late TabController _tabController;

  List<String> moods = ['angry', 'happy', 'sad', 'neutral'];

  int seconds = exercises['angry']![0].time;
  void getNewMood() {
    setState(() {
      int nextMood = random.nextInt(moods.length);
      mood = moods[nextMood];
    });
  }

  void getNewExercise() {
    setState(() {
      exercise_number = random.nextInt(exercises[mood]!.length);
      print("Exercise number: " + exercise_number.toString());
      seconds = exercises[mood]![exercise_number].time;
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        }
        else {
          stopTimer();
        }
      });
    });
  }

  void stopTimer() {
    setState(() {
      timer?.cancel();
    });
  }
 
  void resetTimer() {
    setState(() {
      seconds = exercises[mood]![exercise_number].time;
      print("Seconds: " + seconds.toString());
    });
  }

  String intToTimeLeft(int value) {
    int m, s;

    // h = value ~/ 3600;

    m = value ~/ 60;

    s = value - (m * 60);

    // String hourLeft = h.toString().length < 2 ? "0" + h.toString() : h.toString();

    String minuteLeft = m.toString().length < 2 ? "0" + m.toString() : m.toString();

    String secondsLeft = s.toString().length < 2 ? "0" + s.toString() : s.toString();

    String result = "$minuteLeft:$secondsLeft";

    return result;
    }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }
  @override
  Widget build(BuildContext context) {
    // var exerciseLength = 10;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff81dc17),
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
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider(
              items: List.generate(exercises[mood]![exercise_number].images.length, (index) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      // decoration: BoxDecoration(
                      //   color: Colors.amber
                      // ),
                      child: Image.network(
                        exercises[mood]![exercise_number].images[index],
                        height: 200,
                        width: 200,
                      )
                    );
                  },
                );
              }),
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 2),
                autoPlayAnimationDuration: Duration(milliseconds: 10),
              )
            ),
            // Image.network(
            //   exercises[mood]![exercise_number].images[0],
            //   height: 200,
            //   width: 200,
            // ),
            SizedBox(height: 20,),
            Text(
              exercises[mood]![exercise_number].name.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 400,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), //color of shadow
                    spreadRadius: 5, //spread radius
                    blurRadius: 7, // blur radius
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.lightGreen,
                ),
                tabs: [
                  Tab(text: "Procedure",),
                  Tab(text: "Benefits",)
                ]
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // Text(
                  //   exercises[mood]![exercise_number].procedure,
                  //   style: TextStyle(
                  //     fontFamily: 'Raleway',
                  //   ),
                  // ),
                  GlowingOverscrollColorChanger(
                    color: Colors.lightGreen,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      child: ListView(
                        children: List.generate(exercises[mood]![exercise_number].procedure.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              (index + 1).toString() + ". " + exercises[mood]![exercise_number].procedure[index],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  GlowingOverscrollColorChanger(
                    color: Colors.lightGreen,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      child: ListView(
                        children: List.generate(exercises[mood]![exercise_number].benefits.length, (index) {
                          return Text(
                            exercises[mood]![exercise_number].benefits[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ]
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     exercises[mood]![exercise_number].procedure,
            //     style: TextStyle(
            //       fontFamily: 'Raleway',
            //     ),
            //   ),
            // ),
            SizedBox(height: 20,),
            buildTimer(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  // foregroundColor: Colors.lightGreen,
                  backgroundColor: Colors.lightGreen,
                  onPressed: getNewMood,
                  child: Icon(Icons.mood),
                ),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     primary: Colors.lightGreen,
                //   ),
                //   onPressed: getNewMood,
                //   child: Icon(Icons.mood)
                // ),
                buildButtons(),
                FloatingActionButton(
                  // foregroundColor: Colors.lightGreen,
                  backgroundColor: Colors.lightGreen,
                  onPressed: getNewExercise,
                  child: Icon(Icons.skip_next),
                ),
                  // ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //   primary: Colors.lightGreen,
                  // ),
                  // onPressed: getNewExercise,
                  // child: Icon(Icons.skip_next)),
              ],
            ),
          ],
        ),
      ),
      // body: ListView(
      //   // shrinkWrap: true,
      //   children: List.generate(5, (index) {
      //     return Padding(
      //       padding: const EdgeInsets.symmetric(vertical: 10),
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Container(
      //               height: 150,
      //               width: 190,
      //               decoration: BoxDecoration(
      //                 color: Colors.white,
      //                 borderRadius: BorderRadius.circular(30),
      //                 boxShadow: [BoxShadow(
      //                   color: Colors.grey,
      //                   spreadRadius: 1,
      //                   blurRadius: 10,
      //                   offset: Offset(5, 5)
      //                 )]
      //               ),
      //             ),
      //             Container(
      //               height: 150,
      //               width: 190,
      //               decoration: BoxDecoration(
      //                 color: Colors.white,
      //                 borderRadius: BorderRadius.circular(30),
      //                 boxShadow: [BoxShadow(
      //                   color: Colors.grey,
      //                   spreadRadius: 1,
      //                   blurRadius: 10,
      //                   offset: Offset(5, 5)
      //                 )]
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //     );
      //   }),
      // ),
    );
  }
  Widget buildTimer() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey,
        //     offset: Offset(5, 5)
        //   )
        // ]
      ),
      child: Text(
        intToTimeLeft(seconds),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 50,
          // backgroundColor: Colors.lightGreen,
          color: Colors.white
        ),
      ),
    );
  }

  Widget buildButtons() {
    final isRunning = timer == null ? false : timer!.isActive;
    final isCompleted = seconds == 0;
    return isRunning ?
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.lightGreen,
      ),
        onPressed: () {
        stopTimer();
      },
      child: Icon(Icons.pause))
     : isCompleted ?
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.lightGreen,
      ),
        onPressed: () {
        resetTimer();
      },
      child: Icon(Icons.restart_alt))
     : ElevatedButton(
       style: ElevatedButton.styleFrom(
        primary: Colors.lightGreen,
      ),
       onPressed: () {
        startTimer();
      },
      child: Icon(Icons.play_arrow));
  }
}

class Exercise {
  String name;
  List images = [];
  List<String> procedure;
  List<String> benefits;
  int time;
  Exercise(this.name, this.images, this.procedure, this.benefits, this.time);
}

Map<String, List<Exercise>> exercises = {
  'angry': angry,
  'happy': happy,
  'sad': sad,
  'neutral': neutral,
};

List<Exercise> angry = [
  Exercise(
    "Angry Anulom Vilom",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0', 'https://th.bing.com/th/id/R.4d7c6ac19f89354580f0c2216b3c9079?rik=okNBll9SG31A7A&riu=http%3a%2f%2fpluspng.com%2fimg-png%2fyoga-breathing-png-anulom-vilom-pranayama-yoga-alternate-nostril-breathing-benefits-steps-7pranayama-330.png&ehk=ZuylSqomhzqNdwB5OBr7ZLMM9JuSF9TD%2bBAxxSEpjaA%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Angry Benefits"],
    60
  ),
  Exercise(
    "Angry Kapalbhati",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Angry Benefits"],
    60
  ),
];

List<Exercise> happy = [
  Exercise(
    "Happy Anulom Vilom",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Happy Benefits"],
    60
  ),
  Exercise(
    "Happy Kapalbhati",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Happy Benefits"],
    60
  ),
];
List<Exercise> sad = [
  Exercise(
    "Sad Anulom Vilom",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Sad Benefits"],
    60
  ),
  Exercise(
    "Sad Kapalbhati",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Sad Benefits"],
    60
  ),
];
List<Exercise> neutral = [
  Exercise(
    "Neutral Anulom Vilom",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Neutral Benefits"],
    60
  ),
  Exercise(
    "Neutral Kapalbhati",
    ['https://th.bing.com/th/id/R.3d3e4d81fe70390adfe87aff388b8e8f?rik=DUQJLUHSsaLTwg&riu=http%3a%2f%2fwww.clipartbest.com%2fcliparts%2fjcx%2fa5x%2fjcxa5xeki.png&ehk=jNCjApktl8XfQipLdTtRofphSseVRm%2fGo1ZiPhWfrDI%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
    ["Neutral Benefits"],
    60
  ),
];