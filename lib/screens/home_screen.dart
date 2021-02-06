import 'package:flutter/material.dart';

import 'test_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DropdownMenuItem<int>> _menuItems = List();
  int _numberOfQuestions = 0;

  @override
  void initState() {
    super.initState();
    setMenuItems();
    _numberOfQuestions = _menuItems[0].value;
  }

  void setMenuItems() {
    //普通の記述
//    _menuItems.add(DropdownMenuItem(
//      value: 10,
//      child: Text("10"),
//    ));
//    _menuItems.add(DropdownMenuItem(
//      value: 20,
//      child: Text("20"),
//    ));
//    _menuItems.add(DropdownMenuItem(
//      value: 30,
//      child: Text("30"),
//    ));

    //こっちでも可
//    _menuItems = [
//      DropdownMenuItem(
//        value: 10,
//        child: Text("10"),
//      ),
//      DropdownMenuItem(
//        value: 20,
//        child: Text("20"),
//      ),
//      DropdownMenuItem(
//        value: 30,
//        child: Text("30"),
//      ),
//    ];

    //キャスケード的な記述
    _menuItems
      ..add(DropdownMenuItem(
        value: 10,
        child: Text("10"),
      ))
      ..add(DropdownMenuItem(
        value: 20,
        child: Text("20"),
      ))
      ..add(DropdownMenuItem(
        value: 30,
        child: Text("30"),
      ));
  }

  @override
  Widget build(BuildContext context) {
//    var screenWidth = MediaQuery.of(context).size.width;
//    var screenHeight = MediaQuery.of(context).size.height;
//    print("横幅の論理ピクセル：$screenWidth");
//    print("縦幅の論理ピクセル：$screenHeight");

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/image_title.png"),
                SizedBox(
                  height: 30.0,
                ),
                Text("問題数を選択して「スタート」ボタンを押してください"),
                SizedBox(
                  height: 50.0,
                ),

                //TODO プルダウン選択処理
                DropdownButton(
                  items: _menuItems,
                  value: _numberOfQuestions,
                  //onChangedは選択されたアイテムが変更されたときに実行される
                  onChanged: (selectedValue) =>
                      changeDropdownItem(selectedValue),
                  //下記の書き方もできる
                  //onChanged: => changeDropdownItem,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton.icon(
                      color: Colors.brown,
                      onPressed: () => startTestScreen(context),
                      //TODO ボタン押下時の処理
                      label: Text("スタート"),
                      icon: Icon(Icons.skip_next),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  changeDropdownItem(int selectedValue) {
    setState(() {
      _numberOfQuestions = selectedValue;
    });
  }

  startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  numberOfQuestions: _numberOfQuestions,
                )));
  }
}
