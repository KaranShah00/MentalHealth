import 'package:flutter/material.dart';

import './depression_questionnaire_result_screen.dart';

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

  Widget questionTile(questions, options) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
    itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    questions[index]['question'],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: scores.map((s) {
                    return RadioListTile(
                      title: Text(options[s]!),
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
      appBar: AppBar(title: const Text('Depression Screening')),
      body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    children: const [
                      Text('Please indicate your response for the following questions.'),
                      Divider(thickness: 3,),
                      Text('Over the last 2 weeks, how often have you been bothered by any of the following problems?'),
                    ],
                  ),
                ),
                questionTile(questionList, frequency),
                const Divider(thickness: 5,),
                questionTile(secondaryQuestionList, secondaryFrequency),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return DepressionQuestionnaireResultScreen(sum);
                          }),
                        );
                      },
                      child: const Text('Save Responses')),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
