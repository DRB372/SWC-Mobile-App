import 'package:flutter/material.dart';

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(
    color: Colors.black26,
  ),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
hintStyle: TextStyle(
color: Colors.grey,
),
contentPadding:
EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
border: OutlineInputBorder(
borderRadius: BorderRadius.all(Radius.circular(32.0)),
),
enabledBorder: OutlineInputBorder(
borderSide:
BorderSide(color: Colors.lightBlueAccent, width: 1.0),
borderRadius: BorderRadius.all(Radius.circular(32.0)),
),
focusedBorder: OutlineInputBorder(
borderSide:
BorderSide(color: Colors.lightBlueAccent, width: 2.0),
borderRadius: BorderRadius.all(Radius.circular(32.0)),
),
);