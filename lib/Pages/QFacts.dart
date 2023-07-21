import 'package:flutter/material.dart';
import 'package:flutter_app/Constants/color_constants.dart';
import 'package:flutter_app/Quizzes/QFactsData.dart';
import 'package:flutter_app/Systems/question.dart';
import 'package:flutter_app/Components/ExpandableButton.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'dart:math';
import 'dart:async';
import '../Systems/TFQuestion.dart';
import 'HomePage.dart';

class QFacts extends StatefulWidget {
  const QFacts({super.key});

  @override
  QFactsState createState() => QFactsState();
}

class QFactsState extends State<QFacts> {
  QFactsData q = QFactsData();
  List<String> answerChoicesList = [
    "",
    ""
  ]; //saves choices when answerChoices() is called
  List<TFQuestion> wrongQuestions = []; //could be both vocab + other questions
  List<Color> answerChoiceColors = [
    ColorConstants.buttonColor,
    ColorConstants.buttonColor,
  ];
  int correctChoiceIndex = -1;
  int nQuest = 1;
  double progressPercent = 0;
  int correctlyAnswered = 0;
  List<VoidCallback> buttonFunctions = [];

  QFactsState() {
    initialize();
  }

  AlertDialog? nextQuestion() {
    if (q.isFinished()) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'COMPLETE',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.black,
                  fontFamily: 'M PLUS Code Latin',
                ),
              ),
                content: Padding(
                padding:  const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                '$correctlyAnswered out of ${q.size()} correct.',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'M PLUS Code Latin',
                ),
                ),
                goodImage(),
              ],
            )
                ),
              backgroundColor: ColorConstants.buttonColor,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (correctlyAnswered == q.size()) {
                      q.reset();
                      progressPercent = 0;
                      correctlyAnswered = 0;
                      Navigator.of(context).pop();
                      setState(() {
                        initialize();
                      });
                    }
                    else {
                      q.newCycle(wrongQuestions);
                      progressPercent = 0;
                      correctlyAnswered = 0;
                      Navigator.of(context).pop();
                      setState(() {
                        initialize();
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: ColorConstants.buttonColor,
                  ),
                  child: const Text(
                    'Take Quiz Again',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'M PLUS Code Latin',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                  style: TextButton.styleFrom(
                    backgroundColor: ColorConstants.buttonColor,
                  ),
                  child: const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'M PLUS Code Latin',
                    ),
                  ),
                ),
              ],
            );
          });
    }

    setState(() { //make top not always true
      progressPercent += (100 * (1 / q.size()));
      for (int i = 0; i < 2; i++) {
        //resets answer choice colors to default
        answerChoiceColors[i] = ColorConstants.buttonColor;
      }
      qInfo();
      nQuest++;
      q.nextQuestion();
      changeAnswerChoices();
    });
    return null;
  }

  AlertDialog? qInfo(){
    return const AlertDialog(
      content: Text(
        'q.getQuestion().answerText',
      ),
    );
  }

  void changeAnswerChoices() {
    //only works if there's more than 4 questions in the question bank
    answerChoicesList.clear();

    List<String> choices = ["", ""];
    List<String> wrongChoices = [""];

    correctChoiceIndex = Random().nextInt(1);
    choices[correctChoiceIndex] = q.getCorrectAnswer();

    if(q.getCorrectAnswer() == "True"){
      wrongChoices[0] = "False";
    }
    if(q.getCorrectAnswer() == "False"){
      wrongChoices[0] = "True";
    }

    int j = 0;
    for (int i = 0; i < 2; i++) {
      if (i != correctChoiceIndex) {
        choices[i] = wrongChoices[j];
        j++;
      }
    }

    for (int i = 0; i < 2; i++) {
      answerChoicesList.add(choices[i]);
    }
  }

  void initialize() {
    changeAnswerChoices();
    for (int i = 0; i < 4; i++) {
      buttonFunctions.add(() => questionAnimation(i));
    }
  }

  void check(int choiceIndex) {
    answerChoiceColors[correctChoiceIndex] = ColorConstants
        .correctGreen; //so that right answer displayed when question wrong

    if (choiceIndex != correctChoiceIndex) {
      answerChoiceColors[choiceIndex] = ColorConstants.logoRed;
      wrongQuestions.add(q.getQuestion());
    }
    else {
      correctlyAnswered++;
    }
  }

  Widget goodImage(){
    if(correctlyAnswered/q.size() >= .8){
      return const Image(image: AssetImage('assets/LatinTempCrown.png'));
    }
    else{
      return const SizedBox(
        width: 100,
        height: 100,
      );
    }
  }

  void questionAnimation(int choiceIndex) {
    int time = 1;

    setState(() {
      check(choiceIndex);
    });

    if (choiceIndex != correctChoiceIndex) time = 5;

    for (int i = 0; i < 2; i++) {
      buttonFunctions[i] =
          () => null; //locks out buttons after user answers question
    }

    Timer(Duration(seconds: time), () {
      nextQuestion();
      for (int i = 0; i < 2; i++) {
        buttonFunctions[i] = () => questionAnimation(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteBackround,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Facts',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Neohellenic',
          ),
        ),
        backgroundColor: ColorConstants.buttonColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FAProgressBar(
                size: 5,
                progressColor: ColorConstants.deepPurple,
                currentValue: progressPercent,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$nQuest of ${q.size()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'Neohellenic',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    q.getQuestionText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'Neohellenic',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: SizedBox(
                    height: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandableButton(
                            answerChoicesList[0],
                            buttonFunctions[0],
                            answerChoiceColors[0]), //make function for onPressed
                        ExpandableButton(answerChoicesList[1],
                            buttonFunctions[1], answerChoiceColors[1]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: ColorConstants.buttonColor,
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              OutlinedButton(
                style: TextButton.styleFrom(
                  backgroundColor: ColorConstants.buttonColor,
                ),
                onPressed: null,
                child: const Icon(
                  Icons.settings,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              OutlinedButton(
                style: TextButton.styleFrom(
                  backgroundColor: ColorConstants.buttonColor,
                ),
                child: const Icon(
                  Icons.home,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
              ),
              OutlinedButton(
                style: TextButton.styleFrom(
                  backgroundColor: ColorConstants.buttonColor,
                ),
                onPressed: null,
                child: const Icon(
                  Icons.info,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}