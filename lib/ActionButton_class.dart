import 'package:flutter/material.dart';

class ActionButton {
  String text;
  Color buttonColor;
  Color textColor;
  bool clickStatus;
  int action;
  int channel;
  bool oneClick;
  bool longPress;
  ActionButton(
      {this.text,
        this.buttonColor,
        this.textColor,
        this.clickStatus,
        this.action,
        this.oneClick,
        this.channel,
        this.longPress});
  Map<String, dynamic> toJson() => {
    '"text"': '"$text"',
    '"buttonColor"': buttonColor.value,
    '"textColor"': textColor.value,
    '"clickStatus"': "false",
    '"action"': '"$action"',
    '"channel"': '"$channel"',
    '"oneClick"': '$oneClick',
    '"longPress"': '$longPress',
  };
  factory ActionButton.fromJson(Map<String, dynamic> json) =>
      _actionButtonFromJson(json);
}

ActionButton _actionButtonFromJson(Map<String, dynamic> json) {
  return ActionButton(
    text: json['text'] as String,
    textColor: Color(json['textColor']),
    buttonColor: Color(json['buttonColor']),
    clickStatus: json['clickStatus'] as bool,
    oneClick: json['oneClick'] as bool,
    longPress: json['longPress'] as bool,
    action: int.parse(json['action']),
    channel: int.parse(json['channel']),
  );
}