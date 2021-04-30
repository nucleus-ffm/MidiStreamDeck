import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
//import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/foundation.dart';

import 'selectPreset.dart';
import 'update_class.dart';
import 'ActionButton_class.dart';
import 'Button_widget.dart';
import 'presets.dart';
import 'about.dart';

ThemeData appThemeData;
bool darkMode;

bool editMode = false;
Color editButtonColor = Colors.transparent;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Update(),
      child: Consumer<Update>(
        builder: (context, counter, child) => MaterialApp(
            title: "Midi Stream Deck", home: MyApp(), theme: appThemeData),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  void initState() {}

  @override
  _MYappState createState() => _MYappState();
}

class _MYappState extends State<MyApp> {
  StreamSubscription<String> _setupSubscription;
  MidiCommand _midiCommand = MidiCommand();
  String newButtonText;
  int newButtonAction;
  int newButtonChannel;
  Color newButtonColor;
  String newPresetName;
  bool newOneClick = false;
  bool newLongPress = false;
  String dropdownValue;
  Color saveButtonColor;

  Color appBarColor;
  bool deviceConnected;

  File savedFile;
  int buttonsCount;

  @override
  void initState() {
    super.initState();
    appBarColor = Colors.cyan;
    deviceConnected = false;

    //load file
    print("Lade jetzt alte Daten");
    loadDataFromFile();
    writeGivenPresets();
    loadPresetList();
    buttonListDisplay = buttonList;
    loadSettings();

    _midiCommand.startScanningForBluetoothDevices().catchError((err) {
      print("Error $err");
    });
    _setupSubscription = _midiCommand.onMidiSetupChanged.listen((data) {
      print("setup changed $data");

      switch (data) {
        case "deviceFound":
          setState(() {});
          break;
        case "deviceOpened":
          break;
        default:
          print("Unhandled setup change: $data");
          break;
      }
    });
  }

  Future<void> loadSettings() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    // load DarkMode settings
    if (prefs.getBool('darkMode') != null) {
      print("Load DarkMode settings");
      darkMode = prefs.getBool('darkMode');
      print("darkMode is: " + darkMode.toString());
    } else {
      darkMode = false;
    }

    if (darkMode == true) {
      print("now updatete color Theme to dark");
      ThemeData newColorTheme = ThemeData.dark();
      final updater = Provider.of<Update>(context, listen: false);
      updater.changeColorTheme(newColorTheme, true);
    }
  }

  Future writeGivenPresets() async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File UltraschallFile =
        File(_appDocumentsDirectory.path + '/Ultraschall.txt');
    var data = StringBuffer();
    data.writeln('{"Buttons": [');
    data.writeln(
        '{"text": "Mute Track 1 ", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "16", "channel": "1", "oneClick": false, "longPress": false},');
    data.writeln(
        '{"text": "Play/Pause", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "17", "channel": "1", "oneClick": false, "longPress": false},');
    data.writeln(
        '{"text": "SB Play/Pause 1", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "24", "channel": "2", "oneClick": false, "longPress": false},');
    data.writeln(
        '{"text": "SB Play / Pause 2", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "25", "channel": "2", "oneClick": false, "longPress": false},');
    data.writeln(
        '{"text": "Edit marker", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "16", "channel": "2", "oneClick": true, "longPress": false},');
    data.writeln(
        '{"text": "chapter mark", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "17", "channel": "2", "oneClick": true, "longPress": false},');
    data.writeln(
        '{"text": "Action on Long press", "buttonColor": 4287349578, "textColor": 4294967295, "clickStatus": false, "action": "17", "channel": "2", "oneClick": true, "longPress": true}');

    data.writeln(']}');

    UltraschallFile.writeAsString(data.toString());
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
      //befor deleteing rename it and check if new file is successfully saved
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
    if (await tempFile.exists()) {
      //delete temp file
      tempFile.delete();
    }
    return null;
  }

  Future loadPresetList() async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    //print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/presetList.txt');
    print(presets);
    if (await file.exists()) {
      String contents = await file.readAsString();
      print("im file steht: " + contents);

      dynamic tagObjsJson = json.decode(contents)['Presets'] as List;
      List<dynamic> _presetTemp =
          tagObjsJson.map((tagJson) => tagJson as String).toList();

      presets = List<String>.from(_presetTemp);
      print("presets loaded");
      print(presets);
    } else {
      print("presets does not exists");
      writePresets();
    }
  }

  Future writePresets() async {
    print("now writing the presets");
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/presetList.txt');
    var content = StringBuffer();
    content.write('{"Presets": [');
    presets.forEach((element) {
      content.write('"');
      content.write(element.toString());
      if (element == presets.last) {
        content.write('"');
      } else {
        content.write('",');
      }
    });
    content.write(']}');
    file.writeAsString(content.toString());
  }

  Future<String> loadDataFromFile() async {
    // get file to storage file
    final file = await _getFile("storage");
    // check if the file exsists
    if (await file.exists()) {
      // file exsists
      String contents = await file.readAsString();
      //parse the json into List
      dynamic tagObjsJson = json.decode(contents)['Buttons'] as List;
      List<dynamic> _buttonListTemp =
          tagObjsJson.map((tagJson) => ActionButton.fromJson(tagJson)).toList();
      setState(() {
        //set the List to the List, read out of the file
        buttonListDisplay = List<ActionButton>.from(_buttonListTemp);
        buttonList = buttonListDisplay;
      });
    } else {
      print("file dosen't exists");
      // create file
      writeData();
    }
    return null;
  }

  @override
  void dispose() {
    _setupSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //define the count of cross axis buttons
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //print("width: " + width.toString());
    double st = width / 100;
    //print(st);
    if (st > 6) {
      buttonsCount = 5;
    } else {
      buttonsCount = st.round();
    }

    //choose app Bar Color
    if (deviceConnected == true) {
      appBarColor = Colors.green;
    } else {
      appBarColor = Colors.red;
      print("der zustand ist:" + deviceConnected.toString());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Midi Stream Deck"),
        backgroundColor: appBarColor,
        actions: <Widget>[
          Icon(Icons.edit),
          Switch(
              value: editMode,
              onChanged: (test) {
                setState(() {
                  editMode = test;
                  editButtonColor = Colors.transparent;
                });
              }),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
            icon: Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: () {
              /*setState(() {
                Theme.of(context).primaryColorDark;
              });*/
              if (darkMode == true) {
                darkMode = false;
              } else {
                darkMode = true;
              }

              ThemeData newColorTheme = ThemeData.dark();
              final updater = Provider.of<Update>(context, listen: false);
              updater.changeColorTheme(newColorTheme, darkMode);
            },
            icon: Icon(Icons.color_lens),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PreSetListView()),
              );
            },
            icon: Icon(Icons.list),
          ),
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder: (context, setState) {
                      if (newButtonText != null &&
                          newButtonAction != null &&
                          newButtonColor != null &&
                          newButtonChannel != null) {
                        saveButtonColor = Colors.green;
                      } else {
                        saveButtonColor = Colors.grey;
                      }
                      return AlertDialog(
                        title: new Text('Add new button'),
                        content: new SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              new TextField(
                                decoration: new InputDecoration(
                                  labelText: 'Text',
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    if (text == "") {
                                      newButtonText = null;
                                    } else {
                                      newButtonText = text.trim();
                                    }
                                  });
                                },
                              ),
                              new TextField(
                                decoration: new InputDecoration(
                                  labelText: 'Midi Note (0 - 127)',
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    if (text == "") {
                                      newButtonAction = null;
                                    } else if (int.parse(text.trim()) > 127) {
                                      print("note to height");
                                      newButtonAction = null;
                                    } else {
                                      newButtonAction = int.parse(text.trim());
                                    }
                                  });
                                },
                              ),
                              new TextField(
                                decoration: new InputDecoration(
                                  labelText: 'Midi channel (0 - 16)',
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    if (text == "") {
                                      newButtonChannel = null;
                                    } else if (int.parse(text.trim()) > 16) {
                                      print("channel to height");
                                      newButtonChannel = null;
                                    } else {
                                      newButtonChannel = int.parse(text.trim());
                                    }
                                  });
                                },
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
                                        backgroundColor: newButtonColor,
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
                                          newButtonColor = Colors.cyan;
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
                                          newButtonColor = Colors.green;
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
                                          newButtonColor = Colors.blue;
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
                                          newButtonColor = Colors.orange;
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
                                title: Text("one click"),
                                value: newOneClick,
                                onChanged: (newValue) {
                                  setState(() {
                                    newOneClick = newValue;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .leading, //  <-- leading Checkbox
                              ),
                              CheckboxListTile(
                                title: Text("long press"),
                                value: newLongPress,
                                onChanged: (newValue) {
                                  setState(() {
                                    newLongPress = newValue;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .leading, //  <-- leading Checkbox
                              )
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          new TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          new TextButton(
                            onPressed: () {
                              if (newButtonText != null &&
                                  newButtonAction != null &&
                                  newButtonColor != null &&
                                  newButtonChannel != null) {
                                //save new button if no data is missing
                                ActionButton newButton = ActionButton(
                                    text: newButtonText,
                                    action: newButtonAction,
                                    channel: newButtonChannel,
                                    textColor: Colors.white,
                                    buttonColor: newButtonColor,
                                    clickStatus: false,
                                    oneClick: newOneClick,
                                    longPress: newLongPress);

                                final updater =
                                    Provider.of<Update>(context, listen: false);
                                updater.addNewButtonToList(newButton);
                                setState(() {
                                  //buttonListDisplay.add();
                                  writeData();
                                  print("new List ist saved");
                                  newButtonText = null;
                                  newButtonAction = null;

                                  newButtonColor = null;
                                  newButtonChannel = null;
                                  newOneClick = false;
                                  newLongPress = false;
                                });
                                Navigator.of(context).pop();
                              } else {
                                print("there is data missing");
                              }
                            },
                            child: Text(
                              'save',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: saveButtonColor,
                            ),
                          ),
                        ],
                      );
                    });
                  },
                );
              },
              icon: Icon(Icons.add)),
          /*IconButton(
              onPressed: () {
                _midiCommand
                    .startScanningForBluetoothDevices()
                    .catchError((err) {
                  print("Error $err");
                });
                setState(() {});
              },
              icon: Icon(Icons.refresh)),*/
          IconButton(
              icon: Icon(Icons.devices),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('Choose midi device (BLE or USB)'),
                      content: Container(
                        height: 500,
                        width: 500,
                        child: FutureBuilder(
                          future: _midiCommand.devices,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              var devices = snapshot.data as List<MidiDevice>;
                              return ListView.builder(
                                // Let the ListView know how many items it needs to build
                                itemCount: devices.length,
                                // Provide a builder function. This is where the magic happens! We'll
                                // convert each item into a Widget based on the type of item it is.
                                itemBuilder: (context, index) {
                                  final device = devices[index];

                                  return ListTile(
                                    title: Text(
                                      device.name,
                                      style:
                                          Theme.of(context).textTheme.headline,
                                    ),
                                    trailing: device.type == "BLE"
                                        ? Icon(Icons.bluetooth)
                                        : null,
                                    onTap: () {
                                      _midiCommand.connectToDevice(device);
                                      setState(() {
                                        //change app Bar color
                                        deviceConnected = true;
                                      });
                                      //close window
                                      Navigator.of(context).pop();
                                      /*Navigator.of(context).push(MaterialPageRoute<Null>(
                                      builder: (_) => ControllerPage(),
                                    ));*/
                                    },
                                  );
                                },
                              );
                            } else {
                              print("no device connect");
                              // @TODO: show message
                              return CircularProgressIndicator();
                            }
                            ;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('close'))
                      ],
                    );
                  },
                );
              }),
        ],
      ),
      body: Consumer<Update>(
        builder: (context, counter, child) => CustomScrollView(
          primary: false,
          slivers: <Widget>[
            SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: buttonsCount,
                  children:
                      //@todo show loading screen
                      buttonListDisplay
                          .map((actionButton) => Button(
                                buttonToShow: actionButton,
                              ))
                          .toList(),
                )),
          ],
        ),
      ),
    );
  }
}
