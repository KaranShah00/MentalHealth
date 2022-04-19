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
  final String mood;
  const ExerciseScreen(this.mood, {Key? key}) : super(key: key);

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
  var mood;
  Timer? timer;
  late TabController _tabController;

  // List<String> moods = ['angry', 'happy', 'sad', 'neutral'];

  int seconds = exercises['angry']![0].time;
  // void getNewMood() {
  //   setState(() {
  //     int nextMood = random.nextInt(moods.length);
  //     mood = moods[nextMood];
  //   });
  // }

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
    mood = widget.mood;
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
                      //isAlwaysShown: true,
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
                      //isAlwaysShown: true,
                      child: ListView(
                        children: List.generate(exercises[mood]![exercise_number].benefits.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              (index + 1).toString() + ". " + exercises[mood]![exercise_number].benefits[index],
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
                  heroTag: 1,
                  // foregroundColor: Colors.lightGreen,
                  backgroundColor: Colors.lightGreen,
                  onPressed: resetTimer,
                  child: Icon(Icons.refresh_outlined),
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
                  heroTag: 2,
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
  'fear': fear,
};

List<Exercise> angry = [
  Exercise(
    "Deep Breathing",
    ['https://www.pinclipart.com/picdir/big/556-5565968_breathing-exercise-clipart.png'],
    ["Sit in a comfortable position.", "Place one hand on your stomach, close your eyes and inhale focusing on the air entering your lungs.", "Pause a second before exhaling slowly.", "Focus on breathing, clear your thoughts and calm the muscles"],
    ["It keeps your mind at ease.", "It helps you gather your thoughts and refocus."],
    60
  ),
  Exercise(
      "Anulom Vilom",
      ['https://th.bing.com/th/id/R.02d34fa4c6efdd231c27e1832a5714c8?rik=3ojawGnCx6mlBQ&riu=http%3a%2f%2fpluspng.com%2fimg-png%2fyoga-breathing-png-bhramari-pranayama-bee-breath-243.png&ehk=plBNIn0fAO62jvLRmD3rFc88fr4YUqS97Y0r2Mb36ko%3d&risl=&pid=ImgRaw&r=0', 'https://th.bing.com/th/id/R.4d7c6ac19f89354580f0c2216b3c9079?rik=okNBll9SG31A7A&riu=http%3a%2f%2fpluspng.com%2fimg-png%2fyoga-breathing-png-anulom-vilom-pranayama-yoga-alternate-nostril-breathing-benefits-steps-7pranayama-330.png&ehk=ZuylSqomhzqNdwB5OBr7ZLMM9JuSF9TD%2bBAxxSEpjaA%3d&risl=&pid=ImgRaw&r=0'],
      ["Sit in a comfortable position with your mind and body relaxed.","Close the right nostril with your right thumb and take a deep breath through your left nostril.","Now, remove the thumb from the right nostril and close your left nostril using your ring or little finger.","Exhale slowly through your right nostril.","Repeat, this time inhaling through your left nostril and exhaling through your right.","Continue for one minute."],
      ["It curbs stress, anxietym depression, and anger.", "It balances your mind and open your energy channels."],
      60
  ),
  Exercise(
    "Kapalbhati",
    ['https://th.bing.com/th/id/R.77097c9e938c566112eecf9412fc93bc?rik=Vyemtpd4b%2bnNvA&riu=http%3a%2f%2fwww.premanandyoga.net%2fVideoImages%2fPranayama.jpg&ehk=xryJwkye0dO%2fkvbInpN0kKmPxrzHlRACtyW9UpYreW8%3d&risl=&pid=ImgRaw&r=0'],
    ["Sit in any meditative posture.", "Close the eyes and relax the whole body.", "Inhale deeply through both nostrils, expand the chest.", "Expel the breath with forceful contractions of the abdominal muscles and relax.", "Continue active exhalation and passive inhalation."],
    ["Kapalabhati purifies the frontal air sinuses which helps overcome cough disorders.", "It balances and strengthens the nervous system and tones up the digestive system.", "It relaxes your mind and puts it at ease."],
    60
  ),
  Exercise(
      "Progressive Relaxation",
      ['https://www.tylenol.com/sites/tylenol_us/files/tylenol_pmr.png'],
      ["Lie down while consciously tensing and relaxing your muscles one major muscle group at a time.", "Close your eyes and start with your toes tensing them for a few seconds and then relaxing the muscles.", "Breathe and focus on your body."],
      ["This type of relaxation exercise relieves stress, anger and tension."],
      60
  ),
];

List<Exercise> happy = [
  Exercise(
    "Stair Training",
    ['https://cdn2.iconfinder.com/data/icons/sport-set-1-2/100/sport-colored-Artboard_20-2-512.png'],
    ["With a steady pace, go up and come down on the stairs for at least 5-10 minutes.", "This is a warm-up exercise."],
    ["This exercise burns calories.", "It also pumps more blood from your heart, purifying it."],
    300
  ),
  Exercise(
    "Burpees",
    ['https://2.bp.blogspot.com/-Bhoe9Bhqfmg/Vxe5KH5OuWI/AAAAAAAAAgc/Q-LSNtu-yC052WGUoHgIqUFQMQl9ttDsgCLcB/s1600/BURPEES.png'],
    ["Start off with a standing position with hands on the side.", "Drop down to a squat position but with your palms on the ground.", "Kick your legs back while keeping your arms extended.", "You will be now in a high plank position.", "From high plank position, immediately return to squat position.", "Jump from this position to finish the first rep."],
    ["It is a great conditioning exercise.", "It is a major calorie burn."],
    60
  ),
  Exercise(
    "Dance",
    ['https://images.vexels.com/media/users/3/207720/isolated/preview/e618a6da5344af543a038d54dbb872cb-cute-dancing-couple-by-vexels.png'],
    ["Set up your speakers and play an energetic song.", "Dance your heart out. No instructions are needed for this. Do it the way you like."],
    ["Dancing helps strengthen your heart.", "It greatly increases the energy in your body."],
    300
  ),
  Exercise(
    "Power Skip",
    ['https://th.bing.com/th/id/R.228b618379249100ec9eb83290808f2b?rik=qwjpt51fNSmlCA&riu=http%3a%2f%2fmedia3.popsugar-assets.com%2ffiles%2f2015%2f06%2f28%2f941%2fn%2f1922398%2f927af63ae1ab7440_power-skipnQ5T4B.xxxlarge%2fi%2fPower-Skip.jpg&ehk=C06L%2fgjEvyB11Twwb%2bu2fK9una81y9G9YVreb2LbiwY%3d&risl=&pid=ImgRaw&r=0'],
    ["Stand with feet hip-width apart and core tight", " Raise right knee as you bring left arm forward and hop off left foot", " Land on the ball of your left foot, then immediately bring right foot down and repeat on the other side", " Focus on height, not speed."],
    ["It improves coordination and balance.", "It’s fun!", "It improves flexibility."],
    60
  ),
];
List<Exercise> sad = [
  Exercise(
    "Child's Pose",
    ['https://www.pinclipart.com/picdir/big/540-5400869_extended-childs-pose-01-illustration-clipart.png'],
    ["Come to your hands and knees on the mat.", "Spread your knees as wide as your mat, keeping the tops of your feet on the floor with the big toes touching.", "Bring your belly to rest between your thighs and root your forehead to the floor.", "Stretch your arms in front of you with the palms toward the floor or bring your arms back alongside your thighs with the palms facing upwards."],
    ["It can help relieve back pain.", "Child's Pose is also a gentle stretch for the hips, thighs, and ankles."],
    60
  ),
  Exercise(
    "Bridge Pose",
    ['https://cdn3.iconfinder.com/data/icons/yoga-pose-1/64/yoga-bridge-pose-meditation-512.png'],
    ["Tuck your shoulders under your body then lift your hips to allow your chest to blossom.", "Draw your shoulders under before lifting your hips"],
    ["It creates better posture.", "Constructs a sense of confidence in your mind."],
    60
  ),
  Exercise(
      "Corpse Pose",
      ['https://th.bing.com/th/id/R.1abcc433418ca19c608c6ebe29f3e2b4?rik=B%2fLYBKypYGmaNg&riu=http%3a%2f%2fwww.forteyoga.com%2fwp-content%2fuploads%2f2014%2f01%2fCorpse-Yoga-Pose.png&ehk=xjsgrz5CyuPmWG1VcT5KwGlnJ4eIOySscVLNx%2bQb6VM%3d&risl=&pid=ImgRaw&r=0'],
      ["Lie down on your back.", "Separate your legs. Let go of holding your legs straight so that your feet can fall open to either side.", "Bring your arms alongside your body, but slightly separated from your torso.", "Turn your palms to face upwards but don't try to keep them open. Let the fingers curl in.", "Relax your whole body, including your face. Let your body feel heavy."],
      ["It intensifies your ability to listen to your body, which can help you introspect.", "It balances your digestive system and your stress-coping mechanisms."],
      120
  ),
  Exercise(
      "Heel to Toe Walk",
      ['https://i1.wp.com/physiosunit.com/wp-content/uploads/2016/10/gait2Bcycle2Bstance2Bphase.png?ssl=1'],
      ["Stretch your arms out from your sides to help maintain balance.", "Keep your chin up and parallel to the ground, looking forward.", "As you take a step, place the heel of your foot just in front of the toe of your other foot.", "Walk a straight line in this heel-to-toe fashion. It will feel as if your body is swaying from side to side.", "Take 10 to 20 steps heel-to-toe."],
      ["It can help maintain your center of gravity over your ankles.", "It forces you to maintain physical, and subsequently, mental balance."],
      120
  ),
];
List<Exercise> fear = [
  Exercise(
      "Skipping Rope",
      ['https://cdn4.iconfinder.com/data/icons/dance-fitness-color/300/17-512.png'],
      ["Hold the rope while keeping your hands at hip level.", "Rotate your wrists to swing the rope and jump.", "Jump with both feet at the same time, one foot at a time, alternating between feet."],
      ["This aerobic exercise gets your heart pumping, reduces anxiety and blood pressure.", "Jumping rope can also improve speed, coordination, agility, and balance."],
      60
  ),
  Exercise(
    "Cat-Cow",
    ['https://cdn3.iconfinder.com/data/icons/yoga-pose-set-1-1/512/cat-pose-Marjaryasana-yoga-exercise-512.png', 'https://cdn3.iconfinder.com/data/icons/yoga-pose-set-1-1/512/cow-pose-Bitilasana-yoga-exercise-512.png'],
    ["Start on all fours with your shoulders over your wrists and hips over knees.", "Take a slow inhale, and on the exhale round your spine and drop your head toward the floor (this is the Cat posture).", "Inhale and lift your head, chest, and tailbone toward the ceiling as you arch your back for Cow.", "You should feel a stretch in your spine and possibly your glutes and shoulders as well."],
    ["This pose helps release anger, shame, and anxiety by allowing flow of energy through the body.", "It can stimulate creativity."],
    60
  ),
  Exercise(
      "Downward Facing Dog",
      ['https://www.forteyoga.com/wp-content/uploads/2014/01/23-Downward-Facing-Dog-600x450.png'],
      ["Start on your hands and knees with your hands stacked under your shoulders and knees under your hips.", "Spread your hands wide and press your index finger and thumb into your mat.", "Lift your tailbone and press your butt up and back, drawing your hips toward the ceiling.", "Straighten your legs as best as you can and press your heels gently toward the floor.", "Your head should be relaxed between your arms, facing your knees; your shoulders should be pulled back and down; and your back should be flat."],
      ["This exercise encourages balance and stillness.", "By releasing your head and allowing it to freely hang, you are loosening the tension in your upper body, neck, and head."],
      60
  ),
  Exercise(
      "Forward Fold",
      ['https://cdn3.iconfinder.com/data/icons/yoga-pose-set-2-1/512/seated-forward-bend-pose-Paschimottanasana-yoga-exercise-512.png', 'https://cdn3.iconfinder.com/data/icons/yoga-pose-set-2-1/512/standing-forward-bend-pose-Uttanasana-yoga-exercise-512.png'],
      ["Stand with your feet shoulder-width apart.", "Straighten your legs out as much as you can without locking your knees and let your torso hang down.", "Tuck your chin in toward your chest, relax your shoulders, and extend the crown of your head toward the floor to create a long spine.", "Depending on your flexibility, your hands will touch the floor or dangle above floor level.", "You can hold onto each elbow with the opposite arm or let your arms hang separately."],
      ["It calms the mind by reducing anxiety and worry.", "It soothes the nervous system and encourages introspection."],
      60
  ),
];