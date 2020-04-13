import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: non_constant_identifier_names
void ShowToast(String txt){
  Fluttertoast.showToast(
      msg: txt,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}