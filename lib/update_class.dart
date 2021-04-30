import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'presets.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Update with ChangeNotifier {

  // delete preset
  void updateList(presetName) {
    presets.remove(presetName);
    print("müsste jetzt neubauen");
    notifyListeners();
  }
  //delete Button in Main view
  void updateButtonList(button) {
    buttonListDisplay.remove(button);
    notifyListeners();
  }
  //load preset into main View
  void updateButtonListWithPreset(newButtonList) {
    buttonList = newButtonList;
    notifyListeners();
  }
  void addNewButtonToList(newButton) {
    buttonListDisplay.add(newButton);
    notifyListeners();
  }
  void updateButtonInList() {
    notifyListeners();
  }
  //update Color theme
  void changeColorTheme(newTheme, status) async {
    //newTheme contains the DarkMode Theme later maybe more
    // stratus contains a boolean if darkMode on oder off

    if( status == false ) {
      print("[2] darkmode is: " + darkMode.toString());
      appThemeData = ThemeData.light();
    }
    else if (status ==  true){
      print("darkmode is:" + darkMode.toString());
      appThemeData = ThemeData.dark();
    }
    //save settings in prefs
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    print("write DarkMode settings");
    prefs.setBool("darkMode", status);

    print(appThemeData);
    notifyListeners();
  }
}