import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



Widget BuildNoMoreData() {
  return new Container(
    margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
    alignment: Alignment.center,
    child: new Text("没有更多数据了"),
  );
}

Widget BuildLoadMoreLoading() {
  return new Padding(
    padding: const EdgeInsets.all(8.0),
    child: new Center(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitFadingCircle(
            color: Colors.grey,
            size: 30.0,
          ),
          new Padding(padding: EdgeInsets.only(left: 10)),
          new Text("正在加载更多...")
        ],
      ),
    ),
  );
}