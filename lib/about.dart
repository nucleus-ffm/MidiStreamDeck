import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About this app"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "How to use this app?",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SelectableText(
                'Connect your device to your computer via USB or BLE (Bluetooth Low Energy) and select the MIDI connection type. Then open this app and tap the "Connect Device" button and select the connection you want. Now the app bar will be colored green and you can send midi signals to your computer. On your computer you can now control any program that can handle midi commands. Mostly you can define Midi actions. Or you can use a program that translates Midi signals into keystrokes and use it to control any software you want.'
                    '\n\n All operating systems have a different method to use Midi. A short internet research should help you.'
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Midi... what?",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SelectableText(
                "'Musical Instrument Digital Interface' is a communication protocol that connects a variety of electronic musical instruments. However, Midi can also be used to control, for example, a DAW or any program that can process Midi signals.'",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.info_outline),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Version 0.1 (BETA)",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.perm_identity),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Author: Nucleus",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.business_center),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "licence: not sure... ", //@TODO Lizenz festlegen
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.business_center),
                  SizedBox(
                    width: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LicensePage()),
                      );
                    },
                    child: Text(
                      "licences of used code and plugins... ",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.code),
                    SizedBox(
                      width: 5,
                    ),
                    Text("view source code on Github")
                  ],
                ),
                onPressed: () {
                  _launchInBrowser('https://github.com/nucleus-ffm/MidiStreamDeck');
                },
              ),
              /*TextButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.code),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Get python script (Midi into Key)"),
                  ],
                ),
                onPressed: () {
                  _launchInBrowser("Github.com");
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
