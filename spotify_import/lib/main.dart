import 'package:flutter/material.dart';
import 'theme.dart' as AppThemes;
import 'homepage.dart' as HomePage;
import 'permission_manager.dart' as Perm_Manager;
import 'spotify_manager.dart' as Spotify;

void main() async
{
  /* The main driver for the application */

  //Check and request permissions before loading app
  Perm_Manager.Permission_Manager pm = Perm_Manager.Permission_Manager();

  await pm.get_permissions();

  return runApp(Spotify_Import());
} 

class Spotify_Import extends StatelessWidget {
  /* Root widget of the application */

  Spotify.Spotify_Manager sm = Spotify.Spotify_Manager(); //TODO - Move

  @override
  Widget build(BuildContext context) {
    /* Build the widget title and color scheme */
    sm.server_connect(); //TODO - Move
    return MaterialApp(
      title: 'Spotify Import',

      theme: ThemeData(
        primarySwatch: AppThemes.MainThemeSwatch.swatch,
      ),

      //Create and set homepage widget
      home: HomePage.MyHomePage(title: 'Import Music to Spotify'),

    );
  }
}


