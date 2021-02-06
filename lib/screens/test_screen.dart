import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class TestScreen extends StatefulWidget {
  final numberOfQuestions; //プロパティ(＝フィールド)作成。finalで宣言

  TestScreen({this.numberOfQuestions}); //namedパラメータにして、引数を明示するために｛｝で囲む

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int numberOfRemaining = 0;
  int numberOfCorrect = 0;
  int correctRate = 0;

  int questionLeft = 0;
  int questionRight = 0;
  String operator = "";
  String answerString = "";

  Soundpool _soundpool;
  int soundIdCorrect = 0;
  int soundIdIncorrect = 0;

  bool isCalcButtonEnabled = false;
  bool isAnswerCheckButtonEnabled = false;
  bool isBackButtonEnabled = false;
  bool isCorrectIncorrectImageEnabled = false;
  bool isEndMessageEnabled = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    numberOfCorrect = 0;
    correctRate = 0;
    numberOfRemaining = widget.numberOfQuestions;

    //効果音の準備
    initSounds();

    setQuestion();
  }

  void initSounds() async {
    try {
      _soundpool = Soundpool();
      soundIdCorrect = await loadSound("assets/sounds/sound_correct.mp3");
      soundIdIncorrect = await loadSound("assets/sounds/sound_incorrect.mp3");
      setState(() {});
    } on IOException catch (error) {
      print("エラーの内容は$error");
    }
  }

  Future<int> loadSound(String soundPath) {
    return rootBundle.load(soundPath).then((value) => _soundpool.load(value));
  }

  @override
  void dispose() {
    super.dispose();
    _soundpool.release();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                //スコア表示部分
                _scorePart(),
                //問題表示部分
                _questionPart(),
                //電卓ボタン
                _calcButtons(),
                //答え合わせボタン
                _answerCheckButton(),
                //戻るボタン
                _backButton(),
              ],
            ),
            _correctIncorrectImage(),
            _endMessage(),
          ],
        ),
      ),
    );
  }

  //○×画像表示
  Widget _correctIncorrectImage() {
    if (isCorrectIncorrectImageEnabled == true) {
      if (isCorrect) {
        return Center(child: Image.asset("assets/images/pic_correct.png"));
      }
      return Center(child: Image.asset("assets/images/pic_incorrect.png"));
    } else {
      return Container();
    }
  }

  //テスト終了表示
  Widget _endMessage() {
    if (isEndMessageEnabled) {
      return Center(
          child: Text(
        "テスト終了",
        style: TextStyle(fontSize: 70.0),
      ));
    } else {
      return Container();
    }
  }

  //スコア表示部分
  Widget _scorePart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Table(
        children: [
          TableRow(children: [
            Center(
              child: Text(
                "残り問題数",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                "正解数",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
            Center(
              child: Text(
                "正答率",
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          ]),
          TableRow(
            children: [
              Center(
                child: Text(
                  numberOfRemaining.toString(),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Center(
                child: Text(
                  numberOfCorrect.toString(),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Center(
                child: Text(
                  correctRate.toString(),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //問題表示部分
  Widget _questionPart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 80.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                questionLeft.toString(),
                style: TextStyle(fontSize: 36.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                operator,
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                questionRight.toString(),
                style: TextStyle(fontSize: 36.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "=",
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                answerString,
                style: TextStyle(fontSize: 60.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //電卓ボタン
  Widget _calcButtons() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Table(
          children: [
            TableRow(
              children: [
                _calcButton("7"),
                _calcButton("8"),
                _calcButton("9"),
              ],
            ),
            TableRow(
              children: [
                _calcButton("4"),
                _calcButton("5"),
                _calcButton("6"),
              ],
            ),
            TableRow(
              children: [
                _calcButton("1"),
                _calcButton("2"),
                _calcButton("3"),
              ],
            ),
            TableRow(
              children: [
                _calcButton("0"),
                _calcButton("-"),
                _calcButton("c"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(String numString) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: RaisedButton(
        color: Colors.brown,
        onPressed: isCalcButtonEnabled ? () => inputAnswer(numString) : null,
        child: Text(
          numString,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }

  // 答え合わせボタン
  Widget _answerCheckButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          onPressed: isCalcButtonEnabled ? () => answerCheck() : null,
          color: Colors.brown,
          child: Text(
            "答え合わせ",
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ),
    );
  }

  // 戻るボタン
  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          onPressed: isBackButtonEnabled ? () => closeTestScreen() : null,
          color: Colors.brown,
          //戻るボタン
          child: Text(
            "戻る",
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ),
    );
  }

  // 問題を出題
  void setQuestion() {
    isCalcButtonEnabled = true;
    isAnswerCheckButtonEnabled = true;
    isBackButtonEnabled = false;
    isCorrectIncorrectImageEnabled = false;
    isEndMessageEnabled = false;
    isCorrect = false;
    answerString = "";

    Random random = Random();
    questionLeft = random.nextInt(100) + 1;
    questionRight = random.nextInt(100) + 1;
    if (random.nextInt(2) + 1 == 1) {
      operator = "-";
    } else {
      operator = "+";
    }

    setState(() {}); //2問目移行を表示するため
  }

  inputAnswer(String numString) {
    setState(() {
      if (numString == "c") {
        answerString = "";
        return;
      }
      if (numString == "-") {
        if (answerString == "") answerString = "-";
        return;
      }
      if (numString == "0") {
        if (answerString != "0" && answerString != "-") {
          answerString = answerString + numString;
          return;
        }
      }
      if (answerString == "0") {
        answerString = numString;
        return;
      }

      answerString = answerString + numString;
    });
  }

  answerCheck() {
    if (answerString == "" || answerString == "-") return;

    isCalcButtonEnabled = false;
    isAnswerCheckButtonEnabled = false;
    isBackButtonEnabled = false;
    isCorrectIncorrectImageEnabled = true;
    isEndMessageEnabled = false;

    numberOfRemaining -= 1;

    var myAnswer = int.parse(answerString).toInt();
    var trueAnswer = 0;
    if (operator == "+") {
      trueAnswer = questionLeft + questionRight;
    } else {
      trueAnswer = questionLeft - questionRight;
    }

    if (myAnswer == trueAnswer) {
      isCorrect = true;
      _soundpool.play(soundIdCorrect);
      numberOfCorrect += 1;
    } else {
      isCorrect = false;
      _soundpool.play(soundIdIncorrect);
    }

    correctRate =
        ((numberOfCorrect / (widget.numberOfQuestions - numberOfRemaining)) *
                100)
            .toInt();

    if (numberOfRemaining == 0) {
      //残り問題数が無いとき
      isCalcButtonEnabled = false;
      isAnswerCheckButtonEnabled = false;
      isBackButtonEnabled = true;
      isCorrectIncorrectImageEnabled = true;
      isEndMessageEnabled = true;
    } else {
      //残り問題数があるとき
      Timer(Duration(seconds: 1), () => setQuestion());
    }

    setState(() {});
  }

  closeTestScreen() {
    Navigator.pop(context);
  }
}
