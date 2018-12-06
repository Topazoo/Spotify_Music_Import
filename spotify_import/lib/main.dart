import 'package:flutter/material.dart';
import 'theme.dart' as AppThemes;
import 'homepage.dart' as HomePage;
import 'permission_manager.dart' as Perm_Manager;

void main() async
{
  //Ensure valid permissions
  Perm_Manager.Permission_Manager pm = Perm_Manager.Permission_Manager();
  await pm.get_permissions();
  return runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Import',

      theme: ThemeData(
        primarySwatch: AppThemes.MainThemeSwatch.swatch,
      ),

      home: HomePage.MyHomePage(title: 'Import Music to Spotify'),

    );
  }
}


