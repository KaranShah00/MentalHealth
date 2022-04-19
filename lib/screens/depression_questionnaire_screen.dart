import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './depression_questionnaire_result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepressionQuestionnaireScreen extends StatefulWidget {
  const DepressionQuestionnaireScreen({Key? key}) : super(key: key);

  @override
  _DepressionQuestionnaireScreenState createState() =>
      _DepressionQuestionnaireScreenState();
}

class _DepressionQuestionnaireScreenState
    extends State<DepressionQuestionnaireScreen> {
  List<Map> questionList = [
    {
      'question': "Little interest or pleasure in doing things",
      'score': 0,
    },
    {
      'question': "Feeling down, depressed, or hopeless",
      'score': 0,
    },
    {
      'question': "Trouble falling/staying asleep, sleeping too much",
      'score': 0,
    },
    {
      'question': "Feeling tired or having little energy",
      'score': 0,
    },
    {
      'question': "Poor appetite or overeating",
      'score': 0,
    },
    {
      'question': "Feeling bad about yourself or that you are a failure or have let yourself or your family down",
      'score': 0,
    },
    {
      'question': "Trouble concentrating on things, such as reading the newspaper or watching television.",
      'score': 0,
    },
    {
      'question': "Moving or speaking so slowly that other people could have noticed. Or the opposite; being so fidgety or restless that you have been moving around a lot more than usual.",
      'score': 0,
    },
    {
      'question': "Thoughts that you would be better off dead or of hurting yourself in some way.",
      'score': 0,
    },
  ];

  List<Map> secondaryQuestionList = [
    {
      'question': "If you checked off any problem on this questionnaire so far, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?",
      'score': 0,
    },
  ];

  List<int> scores = [0, 1, 2, 3];

  Map<int, String> frequency = {
    0: "Not at all",
    1: "Several days",
    2: "More than half the days",
    3: "Nearly every day",
  };

  Map<int, String> secondaryFrequency = {
    0: "Not difficult at all",
    1: "Somewhat difficult",
    2: "Very difficult",
    3: "Extremely difficult",
  };

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

  Widget questionTile(questions, options) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
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
                  // gradient: LinearGradient(
                  //   begin: Alignment.centerLeft,
                  //   end: Alignment.centerRight,
                  //   colors: questions.length == 1 ? [Color.fromARGB(255, 128, 128, 128), Color.fromARGB(255, 43, 43, 43)] : color[getNewColor()]!
                  // ),
                  color: Colors.white
              ),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    questions[index]['question'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Colors.black),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: scores.map((s) {
                    return RadioListTile(
                      activeColor: Color.fromARGB(255, 13, 42, 79),
                      title: Text(options[s]!,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300
                      ),),
                      groupValue: questions[index]['score'],
                      value: s,
                      onChanged: (newValue) {
                        setState(() {
                          questions[index]['score'] =
                              int.parse(newValue.toString());
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
         );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depression Checker'),
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
                Color.fromARGB(255, 68, 175, 231),
                Color.fromARGB(255, 13, 42, 79)
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
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       // Text(
                       //   'Remember'.toUpperCase(),
                       //   style: TextStyle(
                       //     fontWeight: FontWeight.bold,
                       //     fontSize: 20,
                       //     letterSpacing: 5,
                       //     color: Colors.white
                       //   ),
                       // ),
                       Padding(
                         padding: const EdgeInsets.only(top: 15.0, left: 10, right: 10),
                         child: Text(
                           'Over the last 2 weeks, how often have you been bothered by any of the following problems?',
                           style: TextStyle(
                            //  color: Colors.white,
                             fontSize: 18,
                             fontWeight: FontWeight.w400
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                  'Remember: Answer truthfully and to the best of your knowledge. False answers may skew the outcome of the questionnaire.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.black
                  ),
              ),
                ),
                questionTile(questionList, frequency),
                SizedBox(height: 20,),
                questionTile(secondaryQuestionList, secondaryFrequency),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(50, 45),
                      primary: Color.fromARGB(255, 3, 31, 103),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23)
                      ),
                    ),
                      onPressed: () {
                        int sum = 0;
                        for (var ques in questionList) {
                        //debugPrint("s: " + ques['score'].toString());
                          sum += ques['score'] as int;
                        }
                        for (var ques in secondaryQuestionList) {
                          //debugPrint("s2: " + ques['score'].toString());
                          sum += (ques['score']) as int;
                        }
                        debugPrint("Sum: $sum");
                        showDepressionResultDialog(context, sum);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) {
                        //     return DepressionQuestionnaireResultScreen(sum);
                        //   }),
                        // );
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
          ),
      ),
    );
  }

  showDepressionResultDialog(BuildContext context, int sum) {
      String resultText;
      if (sum <= 4) {
        resultText = 'The score suggests that you may not need depression treatment.';
      } else if (sum <= 17) {
        resultText = 'The score suggests that mild to moderate symptoms of depression appear to exist, which might warrant closer observation and re-evaluation after a certain period of time.';
      } else {
        resultText = 'The score warrants treatment for depression and you should seek professional help.';
    }
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Result"),
        content: SingleChildScrollView(
          child: Text(resultText),
        ),
        actions: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
            child: Text("Okay",
            style: TextStyle(
              color: Colors.white
            ),),
            color: Color.fromARGB(255, 2, 49, 88),
            onPressed: (){
              Navigator.of(context).pop();
            }
          )
        ],
      );
    });
  }
}
