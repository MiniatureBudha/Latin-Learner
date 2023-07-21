import 'package:flutter/material.dart';
import 'package:flutter_app/Constants/color_constants.dart';

import '../Components/StandardButton.dart';
import 'package:flutter_app/main.dart';

class Intro3 extends StatefulWidget {
  const Intro3({super.key});

  @override
  Intro3State createState() => Intro3State();
}

class Intro3State extends State<Intro3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.whiteBackround,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  color: ColorConstants.whiteBackround
                ),
              ),
              const Center(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Studying Latin is a journey. In doing so, we are living in the past, the present, and the future. It allows us to encounter a world that is so like, and so unlike, our very own. Please use this app to discover, contemplate and admire all of the ways in which we encounter Latin every day.',
                  ),
                ),
              ),
              Center(
                child: Container(
                    width: 50,
                    height: 50,
                    color: ColorConstants.whiteBackround
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: StandardButton("Next", () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  }),
                ),
              ),
            ],
        )
    );
  }
}