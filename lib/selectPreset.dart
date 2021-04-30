import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'update_class.dart';
import 'main.dart';
import 'ActionButton_class.dart';
import 'presets.dart';

class PresetButton extends StatefulWidget {
  final String textToShow;

  PresetButton({this.textToShow});
  @override
  _PresetButtonState createState() => _PresetButtonState();
}

class _PresetButtonState extends State<PresetButton> {
  Future get _getFile async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File storageFile =
        File(_appDocumentsDirectory.path + '/' + widget.textToShow + '.txt');
    return storageFile;
  }

  Future writeData() async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/storage.txt');
    var content = StringBuffer();
    //convert List first to StringBuelementfer and then to String
    //delete old file
    file.delete();

    content.writeln("{");
    content.write('"Buttons": [');
    buttonList.forEach((element) {
      content.write((element.toJson()));
      //ceck if last element -> if no write a , else not
      if (element == buttonList.last) {
      } else {
        content.write(",");
      }
    });
    content.writeln("]}");
    // write in file
    return file.writeAsString(content.toString());
  }

  Future<String> loadDataFromFile(presetName) async {
    print("Lade Daten");
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/' + presetName + '.txt');
    print("habe nur Datei");
    // Read the file
    print(await file.exists());
    if (await file.exists()) {
      print("Datei existiert");
      String contents = await file.readAsString();
      print('im File steht: ' + contents);
      //print("Now load old List");
      //var temButton = _actionButtonFromJson(json.decode(contents) as List);
      //print("alte List" + _buttonList.toString());

      print("new List");
      dynamic tagObjsJson = json.decode(contents)['Buttons'] as List;
      print("---");
      List<dynamic> _buttonListTemp =
          tagObjsJson.map((tagJson) => ActionButton.fromJson(tagJson)).toList();
      print("---");
      //print(_buttonListTemp);
      print("Now old is new");
      setState(() {
        //print("Die Länge ist:"+_buttonListDisplay.length.toString());
        buttonListDisplay = List<ActionButton>.from(_buttonListTemp);
        print("done");
        final updater = Provider.of<Update>(context, listen: false);
        writeData();
        updater.updateButtonListWithPreset(buttonListDisplay);
      });

      print("ist ist jetzt:");
      print(buttonListDisplay);
      print("jetzt müsste die button List wieder geladen sein");
      return '';
    } else {
      print("Datei existerit noch nicht");
      //writeData();
      return '';
    }
  }

  Future<String> deletePreset(presetName) async {
    print("Lade Daten");
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/' + presetName + '.txt');

    // Read the file
    if (await file.exists()) {
      file.delete();
      print("Preset removed");
    } else {
      print("Datei existerit nicht");

      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 100,
            child:
            TextButton(
              onPressed: () async {
                // load File
                loadDataFromFile(widget.textToShow);
                //close Alert Dialog
                Navigator.of(context).pop();
              },
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(widget.textToShow),
                ),
            )
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deletePreset(widget.textToShow);
              final counter = Provider.of<Update>(context, listen: false);
              counter.updateList(widget.textToShow);
            },
            color: Colors.red,
          )
        ],
      ),
    );
  }
}

class PreSetListView extends StatefulWidget {
  @override
  _PreSetListViewState createState() => _PreSetListViewState();
}

class _PreSetListViewState extends State<PreSetListView> {
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

  /*Future loadPresetList() async {
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
    //print("path ist:" + _appDocumentsDirectory.toString());
    File file = File(_appDocumentsDirectory.path + '/presetList.txt');
    if (await file.exists()) {
      String contents = await file.readAsString();
      print("im file steht: " + contents);

      dynamic tagObjsJson = json.decode(contents)['Presets'] as List;
      List<dynamic> _presetTemp =
      tagObjsJson.map((tagJson) => tagJson as String).toList();
      presets = List<String>.from(_presetTemp);
      print("presetList loaded");
    } else {
      writePresets();
    }
  }*/

  /* void function to wirte the new presetList zu file  */
  Future<void> writePresets() async {
    print("now writing the presets");
    Directory _appDocumentsDirectory = await getExternalStorageDirectory();
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

  Future<void> saveCurrentButtons(presetName) async {
    //get file to new presetfile
    File file = await _getFile(presetName);
    File tempFile = await _getFile("tempFile");
    // get path to tempfile
    final tempPath = await _getPath("tempFile");

    var content = StringBuffer();
    //convert List first to StringBuffer and then to String
    if (await file.exists()) {
      //before deleting rename it and check if new file is successfully saved
      file.rename(tempPath);
    }
    try {
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
      //add to preset list und update view
      setState(() {
        presets.add(presetName);
        writePresets();
        print("preset added");
        print(presets);
      });
    } catch (error) {
      print("Error:" + error);
    }
    ;
    if (await tempFile.exists()) {
      //delete tempfile
      tempFile.delete();
    }
    return null;
  }



  String newPresetName;
  final fieldText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //final counter = Provider.of<Update>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("select preset"),
        ),
        body: Consumer<Update>(
          builder: (context, counter, child) => Container(
            //width: 500,
            //height: 500,
            child: ListView(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Save current buttons as preset",
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 85,
                          child: TextField(
                            decoration: new InputDecoration(
                              labelText: 'Please enter a preset name.',
                            ),
                            onChanged: (text) {
                              setState(() {
                                newPresetName = text.trim();
                              });
                            },
                            controller: fieldText,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.save),
                          onPressed: () {
                            //check if name was entered
                            if (newPresetName != null) {
                              saveCurrentButtons(newPresetName);
                              fieldText.clear();
                            } else {
                              print("no name was entered");
                            }
                          },
                        )
                      ],
                    ),
                    Divider(),
                    Text(
                      "load preset",
                      style: TextStyle(fontSize: 20),
                    ),
                    ...presets
                        .map((text) => PresetButton(
                      textToShow: text,
                    ))
                        .toList(),
                  ],
                ),
              ),

            ]),
          ),
        ));
  }
}
