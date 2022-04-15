import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          title: const Text('Questionnaire')),
      body: Container(
          color:Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                  child: Column(
                    children: const [
                      Text('Please indicate your response for the following questions.'),
                      Text('1	represents Not at all, 7 represents An extreme amount.'),
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
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  questionList[index]['question'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.black),
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
                  child: ElevatedButton(onPressed: () {
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
                    emotions.forEach((key, value) {
                      if(value > score) {
                        score = value;
                        mood = key.toLowerCase();
                      }
                    });
                  } , child: const Text('Save Responses')),
                ),
              ],
            ),
          )
      ),
    );
  }
}