import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:midi_stream_deck/update_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'presets.dart';
import 'main.dart';
import 'ActionButton_class.dart';

class Button extends StatefulWidget {
  final ActionButton buttonToShow;

  Button({this.buttonToShow});

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  String dropdownValue;
  Color buttonColor;
  bool checkboxValue = false;
  bool inputIsCorrect;
  Color closeButtonColor;
  //midi
  var _channel = 0;
  var _controller = 0;
  var _value = 0;

  //longPres
  bool isPressed;

  var buttonTextController = TextEditingController();
  var buttonMidiNoteController = TextEditingController();
  var buttonMidiChannelController = TextEditingController();

  StreamSubscription<MidiPacket> _rxSubscription;
  MidiCommand _midiCommand = MidiCommand();

  @override
  void initState() {
    // print('init controller');
    _rxSubscription = _midiCommand.onMidiDataReceived.listen((packet) {
      // print('received packet $packet');
      var data = packet.data;
      var timestamp = packet.timestamp;
      var device = packet.device;
      print(
          "data $data @ time $timestamp from device ${device.name}:${device.id}");

      var status = data[0];

      if (status == 0xF8) {
        // Beat
        return;
      }

      if (status == 0xFE) {
        // Active sense;
        return;
      }

      if (data.length >= 2) {
        var d1 = data[1];
        var d2 = data[2];
        var rawStatus = status & 0xF0; // without channel
        var channel = (status & 0x0F);
        if (rawStatus == 0xB0 && channel == _channel && d1 == _controller) {
          setState(() {
            _value = d2;
          });
        }
      }
    });
    super.initState();
  }

  void dispose() {
    _rxSubscription.cancel();
    super.dispose();
  }

  Future _getFile(fileName) async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    //print("path ist:" + _appDocumentsDirectory.toString());
    File storageFile =
        File(_appDocumentsDirectory.path + '/' + fileName + '.txt');
    return storageFile;
  }

  Future _getPath(fileName) async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    //print("path ist:" + _appDocumentsDirectory.toString());
    final path = _appDocumentsDirectory.path + '/' + fileName + '.txt';
    return path;
  }

  Future writeData() async {
    final file = await _getFile("storage");
    final tempFile = await _getFile("tempFile");
    final tempPath = await _getPath("tempFile");
    var content = StringBuffer();
    //convert List first to StringBuelementfer and then to String
    //delete old file
    if (await file.exists()) {
      //before deleteing rename it and check if new file is successfully saved
      file.rename(tempPath);
    }
    try {
      //print("Die Länge ist:" + _buttonList.length.toString());
      //prepare StringBuffer to write in file
      content.writeln("{");
      content.writeln('"Buttons": [');
      buttonList.forEach((element) {
        content.write((element.toJson()));
        //check if last element -> if no write a , else not
        if (element == buttonList.last) {
        } else {
          content.writeln(",");
        }
      });
      content.write("\n");
      content.writeln("]}");
      // write in file
      // @Todo: check if file was successfully created
      file.writeAsString(content.toString());
    } catch (error) {
      print("Error:" + error);
    }
    ;
    //tempFile.delete();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buttonToShow.oneClick == false && widget.buttonToShow.longPress == false) {
      if (widget.buttonToShow.clickStatus == false) {
        buttonColor = widget.buttonToShow.buttonColor;
      } else {
        buttonColor = Colors.red;
      }
    } else if ((widget.buttonToShow.longPress == true || widget.buttonToShow.oneClick == true) && (isPressed == false || isPressed == null)) {
      buttonColor = widget.buttonToShow.buttonColor;
    }

    //set values to textFields
    buttonTextController.text = widget.buttonToShow.text;
    buttonMidiNoteController.text = widget.buttonToShow.action.toString();
    buttonMidiChannelController.text = widget.buttonToShow.channel.toString();


    return GestureDetector(
      onPanDown: (_) async {
        if (widget.buttonToShow.longPress == true && editMode == false) {
          print("OnLongPressStart");
          print("send Note on");
          NoteOnMessage(
              channel: widget.buttonToShow.channel,
              note: widget.buttonToShow.action,
              velocity: 100)
              .send();
          isPressed = true;
          setState(() {
            print("Button is red");
            buttonColor = Colors.red;
          });
          int i = 1;
          while (isPressed) {
            print('long pressing' + i.toString());
            i++;
            await Future.delayed(Duration(milliseconds: 100));
          }
        } else {}
      },
      onPanCancel: () {
        if (widget.buttonToShow.longPress == true && editMode == false) {
          print("send Note off");
          NoteOffMessage(
              channel: widget.buttonToShow.channel,
              note: widget.buttonToShow.action,
              velocity: 0)
              .send();
          setState(() {
            isPressed = false;
            setState(() {
              print("button is back");
              buttonColor = widget.buttonToShow.buttonColor;
            });
            print("pressed ended");
          });
        } else {}
      },
      child: TextButton(
        onPressed: () {
          if (editMode == true) {
            // edit button

            inputIsCorrect = true;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  if (inputIsCorrect == true) {
                    closeButtonColor = Colors.green;
                  } else {
                    closeButtonColor = Colors.grey;
                  }
                  return AlertDialog(
                    title: new Text('Edit button'),
                    content: new SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          new TextField(
                            decoration: new InputDecoration(
                              labelText: 'Text',
                              hintText: 'now: ' + widget.buttonToShow.text,
                            ),
                            onChanged: (text) {
                              setState(() {
                                widget.buttonToShow.text = text.trim();

                              });
                            },
                            controller: buttonTextController,
                          ),
                          new TextField(
                            decoration: new InputDecoration(
                              labelText: 'Midi note (0 - 127)',
                              hintText: 'now: ' +
                                  widget.buttonToShow.action.toString(),
                            ),
                            onChanged: (text) {
                              if (text != "" && int.parse(text) < 128) {
                                setState(() {
                                  inputIsCorrect = true;
                                  widget.buttonToShow.action =
                                      int.parse(text.trim());
                                });
                              } else {
                                print("Note to height");
                                setState(() {
                                  inputIsCorrect = false;
                                });
                              }
                            },
                            controller: buttonMidiNoteController,
                          ),
                          new TextField(
                            decoration: new InputDecoration(
                              labelText: 'Midi channel (0 - 16)',
                              hintText: 'now: ' +
                                  widget.buttonToShow.channel.toString(),
                            ),
                            onChanged: (text) {
                              if (text != "" && int.parse(text) < 17) {
                                setState(() {
                                  inputIsCorrect = true;
                                  widget.buttonToShow.channel =
                                      int.parse(text.trim());
                                });
                              } else {
                                print("channel to height");
                                setState(() {
                                  inputIsCorrect = false;
                                });
                              }
                            },
                            controller: buttonMidiChannelController,
                          ),
                          Row(
                            children: <Widget>[
                              Text("Selected color is:"),
                              Container(
                                width: 50,
                                padding: EdgeInsets.all(1),
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        widget.buttonToShow.buttonColor,
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                padding: EdgeInsets.all(1),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.buttonToShow.buttonColor =
                                          Colors.cyan;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                padding: EdgeInsets.all(1),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.buttonToShow.buttonColor =
                                          Colors.green;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                padding: EdgeInsets.all(1),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.buttonToShow.buttonColor =
                                          Colors.blue;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                padding: EdgeInsets.all(1),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.buttonToShow.buttonColor =
                                          Colors.orange;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CheckboxListTile(
                            title: Text("one click "),
                            value: widget.buttonToShow.oneClick,
                            onChanged: (newValue) {
                              setState(() {
                                widget.buttonToShow.oneClick = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          CheckboxListTile(
                            title: Text("long press"),
                            value: widget.buttonToShow.longPress,
                            onChanged: (newValue) {
                              setState(() {
                                widget.buttonToShow.longPress = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          print("delete Button");
                          setState(() {
                            buttonList.remove(widget.buttonToShow);
                            //buttonListDisplay.remove(widget.ButtonToShow);
                            writeData();
                            final counter = Provider.of<Update>(context, listen: false);
                            counter.updateButtonList(widget.buttonToShow);
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "delete",
                          style: TextStyle(color: Colors.white),
                        ),
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                      ),
                      TextButton(
                        onPressed: () {
                          if (inputIsCorrect == true) {
                            final counter = Provider.of<Update>(context, listen: false);
                            counter.updateButtonInList();
                            Navigator.of(context).pop();
                            writeData();
                          } else {
                            print("data is nor correct");
                          }
                        },
                        child: Text(
                          'close',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: closeButtonColor,
                        ),
                      ),
                    ],
                  );
                });
              },
            );
          } else {
            // change button click Status
            setState(
              () {
                if (widget.buttonToShow.longPress != true)  {
                  if (widget.buttonToShow.clickStatus == false ) {
                    setState(() {
                      //enable stuff
                      widget.buttonToShow.clickStatus = true;
                      print("Sending midi message ON");
                      /*CCMessage(channel: 1, controller: 1 , value: 127)
                    .send();*/
                      NoteOnMessage(
                          channel: widget.buttonToShow.channel,
                          note: widget.buttonToShow.action,
                          velocity: 100)
                          .send();
                      NoteOffMessage(
                          channel: widget.buttonToShow.channel,
                          note: widget.buttonToShow.action,
                          velocity: 0)
                          .send();
                    });
                  } else {
                    setState(() {
                      //disable stuff
                      widget.buttonToShow.clickStatus = false;
                      print("Sending midi message OFF");
                      /*CCMessage(channel: widget.ButtonToShow.action, controller: _controller , value: 0)
                    .send();*/
                      print("send on channel:" +
                          widget.buttonToShow.channel.toString());
                      NoteOnMessage(
                          channel: widget.buttonToShow.channel,
                          note: widget.buttonToShow.action,
                          velocity: 100)
                          .send();
                      NoteOffMessage(
                          channel: widget.buttonToShow.channel,
                          note: widget.buttonToShow.action,
                          velocity: 0)
                          .send();
                    });
                  }
                }
              },
            );
          }
        },
        child: Text(
          widget.buttonToShow.text,
          style:
              TextStyle(color: widget.buttonToShow.textColor, fontSize: 17.0),
        ),
        style: TextButton.styleFrom(backgroundColor: buttonColor),
      ),
    );
  }
}
