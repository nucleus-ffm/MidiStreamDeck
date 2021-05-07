# MidiStreamDeck
## About
With this app you can send midi signals from your smartphone to your computer via USB or BLE (BLE is not tested yet). This way you can control all programs on your computer, provided that the program supports midi. For example, during a podcast recording, you can control your DAW (Digital Audio Workstation) without having to use the keyboard or mouse. With just one click you can mute yourself to clear your throat, or play a sound from the soundboard. Basically any action in a DAW can be controlled by midi signals. If you use a program that can convert midi signals into keystrokes, you have even more possibilities. For example, you can easily mute yourself in a video conference or similar. 

There are also hardware solutions for this. Even though they have some advantages, they are usually quite expensive and have only a very limited number of buttons. The same task, can also be done by an (old) cell phone or better yet tablet. 

This app is still in a testing phase. I think everything works so far, but if you notice any bugs, please open an issue. If you have any idea how this app can be improved, please tell me as well. I am always open to new ideas. If you think this app is awesome, I would love for you to tell me about it.  

## How does it work?
Connect your device to your computer via USB or BLE (Bluetooth Low Energy) and select the MIDI connection type. Then open this app and tap the "Connect Device" button and select the connection you want. Now the app bar will be colored green and you can send midi signals to your computer. On your computer you can now control any program that can handle midi commands. Mostly you can define Midi actions. Or you can use a program that translates Midi signals into keystrokes and use it to control any software you want.'

All operating systems have a different method to use Midi. A short internet research should help you.

## FAQ
**I cannot select a Midi device in the app?**  
Please check whether you have selected the Midi connection type. 

**I have created a nice preset, can I transfer it?**  
Yes, all presets are stored in "android/data/de.nucleusTech.midi_stream_deck/files". If you want to transfer them, just copy the whole folder. If you want to transfer a single preset, note that you need to add the preset in the "PresetList.txt" file. The presets are saved in Json format. 

