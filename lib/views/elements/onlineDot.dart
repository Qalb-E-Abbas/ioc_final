
import 'package:flutter/material.dart';

Container customOnlineDot(Color color){
  return Container(
    height: 10,
    width: 10,
    decoration: BoxDecoration(
        color: color,
        shape:  BoxShape.circle
    ),
  );
}