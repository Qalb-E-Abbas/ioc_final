import 'package:flutter/material.dart';

Container customOnlineDot(Color color) {
  return Container(
    height: 17,
    width: 17,
    decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2)),
  );
}
