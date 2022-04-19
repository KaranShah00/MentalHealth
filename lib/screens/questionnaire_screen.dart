import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health/screens/recommendation_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  List<Map> questionList=[
    {
    'question':'Did you feel angry or enraged today?',
    'emotion': 'Angry',
    'score': 1
    },
    {
      'question':'Did people find you easy going and approachable?',
      'emotion': 'Happy',
      'score': 1
    },
    {
      'question':'Did you feel lonely or empty?',
      'emotion': 'Sad',
      'score': 1
    },
    {
      'question':'Were you anxious today?',
      'emotion': 'Fear',
      'score': 1
    },
    {
      'question':'Are you feeling relaxed and calm?',
      'emotion': 'Happy',
      'score': 1
    },
    {
      'question':'Did you do something that you enjoy doing today?',
      'emotion': 'Happy',
      'score': 1
    },
    {
      'question':'Are you upset about something?',
      'emotion': 'Sad',
      'score': 1
    },
    {
      'question':'Are you content with your day today?',
      'emotion': 'Happy',
      'score': 1
    },
  ];

  Map<String, int> total = {
    "Angry": 0,
    "Happy": 0,
    "Sad": 0,
    "Fear": 0,
  };

  Map<String, int> counts = {
    "Angry": 0,
    "Happy": 0,
    "Sad": 0,
    "Fear": 0,
  };

  Map<String, double> emotions = {
    "Angry": 0,
    "Happy": 0,
    "Sad": 0,
    "Fear": 0,
  };

  List<int> scores = [1, 2, 3, 4, 5, 6, 7];
  Map<int, List<Color>> color = {
    0: [Color.fromARGB(255, 255, 111, 0),Color.fromARGB(255, 220, 23, 23),],
    1: [Color.fromARGB(255, 68, 175, 231),Color.fromARGB(255, 13, 42, 79)],
    2: [Color.fromARGB(255, 115, 202, 0), Color.fromARGB(255, 20, 147, 3),],
    3: [Color.fromARGB(255, 255, 217, 59),Color.fromARGB(255, 255, 186, 0),],
    4: [Color.fromARGB(255, 108, 0, 250), Color.fromARGB(255, 51, 5, 119),],
  };

  // var random = new Random();
  int colorIndex = 0;

  int getNewColor() {
    // setState(() {
    //   colorIndex = random.nextInt(5);
    //   // print("Exercise number: " + exercise_number.toString());
    //   // seconds = exercises[mood]![exercise_number].time;
    // });
    return (colorIndex++)%5;
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          title: const Text('Questionnaire'),
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
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 115, 202, 0),
                Color.fromARGB(255, 20, 147, 3)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp
            ),
          ),
        ),
      ),
      body: Container(
          color:Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                  child: Column(
                    children: const [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 10, right: 10),
                        child: Text(
                          'Please indicate your response for the following questions.',
                           style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.w400
                             ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          '1	represents Not at all, 7 represents An extreme amount.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  ListView.builder(
                    shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questionList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // elevation: 10,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            // height: 120,
                            // width: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), //color of shadow
                                  spreadRadius: 5, //spread radius
                                  blurRadius: 7, // blur radius
                                  offset: Offset(0, 2),
                                )
                              ],
                              color: Colors.white
                                // gradient: LinearGradient(
                                //   begin: Alignment.centerLeft,
                                //   end: Alignment.centerRight,
                                //   colors: color[getNewColor()]!
                                // ),
                            ),
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  questionList[index]['question'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: scores.map((s){
                                      return Column(
                                        children: <Widget>[
                                          Radio(
                                            activeColor: Color.fromARGB(255, 20, 147, 3),
                                            groupValue: questionList[index]['score'],
                                            value: s,
                                            onChanged: (newValue) {
                                              setState((){
                                                questionList[index]['score'] = int.parse(newValue.toString());
                                              });
                                            },
                                          ),
                                          Text(s.toString(), style: const TextStyle(color:Colors.black))
                                        ],
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(50, 45),
                      primary: Color.fromARGB(255, 20, 147, 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23)
                      ),
                    ),
                    onPressed: () {
                      for(var ques in questionList) {
                        counts[ques["emotion"]] = counts[ques["emotion"]]! + 7;
                        total[ques["emotion"]] = total[ques["emotion"]]! + (ques["score"]) as int;
                      }
                      for (var key in emotions.keys) {
                        emotions[key] = total[key]! / counts[key]!;
                      }
                      debugPrint("c: " + counts.toString());
                      debugPrint("t: " + total.toString());
                      debugPrint("e: " + emotions.toString());
                      var mood;
                      double score = 0;
                      double happyScore = 0;
                      emotions.forEach((key, value) {
                        if(key.toLowerCase() == 'happy') {
                          happyScore = value;
                        }
                        if(value > score) {
                          score = value;
                          mood = key.toLowerCase();
                        }
                      });
                      firestore.collection('users').doc(user?.uid).collection('variables').doc('Mood').collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': happyScore, 'target': 1}, SetOptions(merge: true));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return RecommendationScreen(mood);
                        }),
                      );
                    },
                    child: const Text(
                      'Save Responses',
                      style: TextStyle(
                        fontWeight: FontWeight.w300
                      ),
                    )
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}