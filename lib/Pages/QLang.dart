import 'package:flutter/material.dart';
import 'package:flutter_app/Constants/color_constants.dart';
import 'package:flutter_app/Systems/question.dart';
import 'package:flutter_app/Quizzes/QLangData.dart';
import 'package:flutter_app/Components/ExpandableButton.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'dart:math';
import 'dart:async';
import 'HomePage.dart';

class QLang extends StatefulWidget {
  const QLang({super.key});

  @override
  QLangState createState() => QLangState();
}

class QLangState extends State<QLang> {
  QLangData q = QLangData();
  List<String> answerChoicesList = [
    "",
    "",
    "",
    ""
  ]; //saves choices when answerChoices() is called
  List<Question> wrongQuestions = []; //could be both vocab + other questions
  List<Color> answerChoiceColors = [
    ColorConstants.buttonColor,
    ColorConstants.buttonColor,
    ColorConstants.buttonColor,
    ColorConstants.buttonColor
  ];
  int correctChoiceIndex = -1;
  double progressPercent = 0;
  int nQuest = 1;
  int correctlyAnswered = 0;
  List<VoidCallback> buttonFunctions = [];

  QLangState() {
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
                  color: Colors.white,
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
              backgroundColor: ColorConstants.whiteBackround,
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

    setState(() {
      progressPercent += (100 * (1 / q.size()));
      for (int i = 0; i < 4; i++) {
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

    List<String> choices = ["", "", "", ""];
    List<String> wrongChoices = ["", "", ""];

    correctChoiceIndex = Random().nextInt(4);
    choices[correctChoiceIndex] = q.getCorrectAnswer();

    for (int i = 0; i < 3; i++) {
      String wrongAns = "";
      if(i == 0){
        wrongAns = q.getQuestion().wrongAns1;
      }
      else if(i == 1){
        wrongAns = q.getQuestion().wrongAns2;
      }
      else if(i == 2){
        wrongAns = q.getQuestion().wrongAns3;
      }
      while (wrongAns == q.getCorrectAnswer()) {
        wrongAns = q.randomAnswer();
      }
      wrongChoices[i] = wrongAns;
    }

    while (wrongChoices[0] == wrongChoices[1] ||
        wrongChoices[0] == wrongChoices[2] ||
        wrongChoices[1] == wrongChoices[2]) {
      if (wrongChoices[0] == wrongChoices[1]) {
        String randomAnswer = q.randomAnswer();

        while (randomAnswer == q.getCorrectAnswer()) {
          randomAnswer = q.randomAnswer();
        }

        wrongChoices[1] = randomAnswer;
      }

      if (wrongChoices[0] == wrongChoices[2]) {
        String randomAnswer = q.randomAnswer();

        while (randomAnswer == q.getCorrectAnswer()) {
          randomAnswer = q.randomAnswer();
        }

        wrongChoices[2] = randomAnswer;
      }

      if (wrongChoices[1] == wrongChoices[2]) {
        String randomAnswer = q.randomAnswer();

        while (randomAnswer == q.getCorrectAnswer()) {
          randomAnswer = q.randomAnswer();
        }

        wrongChoices[2] = randomAnswer;
      }
    } //makes sure choices all distinct

    int j = 0;
    for (int i = 0; i < 4; i++) {
      //potential trouble spot
      if (i != correctChoiceIndex) {
        choices[i] = wrongChoices[j];
        j++;
      }
    }
    for (int i = 0; i < 4; i++) {
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

    for (int i = 0; i < 4; i++) {
      buttonFunctions[i] =
          () => null; //locks out buttons after user answers question
    }

    Timer(Duration(seconds: time), () {
      nextQuestion();
      for (int i = 0; i < 4; i++) {
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
          'Latin Language',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'M PLUS Code Latin',
          ),
        ),
        backgroundColor: ColorConstants.buttonColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
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
                      fontFamily: 'M PLUS Code Latin',
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
                            answerChoiceColors[
                                0]), //make function for onPressed
                        ExpandableButton(answerChoicesList[1],
                            buttonFunctions[1], answerChoiceColors[1]),
                        ExpandableButton(answerChoicesList[2],
                            buttonFunctions[2], answerChoiceColors[2]),
                        ExpandableButton(answerChoicesList[3],
                            buttonFunctions[3], answerChoiceColors[3]),
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