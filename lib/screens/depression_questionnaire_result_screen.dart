import 'package:flutter/material.dart';

class DepressionQuestionnaireResultScreen extends StatelessWidget {
  final int resultScore;

  DepressionQuestionnaireResultScreen(this.resultScore);

  String get resultPhrase {
    String resultText;
    if (resultScore <= 4) {
      resultText = 'The score suggests that you may not need depression treatment.';
    } else if (resultScore <= 17) {
      resultText = 'The score suggests that mild to moderate symptoms of depression appear to exist, which might warrant closer observation and re-evaluation after a certain period of time.';
    } else {
      resultText = 'The score warrants treatment for depression and you should seek professional help.';
    }
    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                resultPhrase,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }
}