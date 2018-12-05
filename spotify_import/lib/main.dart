import 'package:flutter/material.dart';
import 'theme.dart' as AppThemes;
import 'homepage.dart' as HomePage;
import 'audio_fs.dart' as Audio_FS;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // Class to access and retrieve audio files
  Audio_FS.Audio_Filesystem audio_fs = Audio_FS.Audio_Filesystem();

  @override
  Widget build(BuildContext context) {
    audio_fs.fetch_audio(); //TODO - Remove or pass to class
    return MaterialApp(
      title: 'Spotify Import',

      theme: ThemeData(
        primarySwatch: AppThemes.MainThemeSwatch.swatch,
      ),

      home: HomePage.MyHomePage(title: 'Import Music to Spotify'),

    );
  }
}


