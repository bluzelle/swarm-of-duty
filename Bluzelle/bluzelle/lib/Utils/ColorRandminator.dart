import 'package:flutter/material.dart';

class ColorRandominator{
  static int index=0;
  static List colorList = [
    Colors.blue,
    Colors.deepOrange,
    Colors.green,
    Colors.teal,
    Colors.orange
  ];
  static getColor(){
    if(index == colorList.length-1){
      index = 0;
    }else {
      index++;
    }
    return colorList[index];
  }
}