import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'spotify_widget.dart';
import 'dart:io';

class Spotify_Manager {
  String authUrl;
  String accessCode;
  int retCode;
  State<Spotify_Widget> wid;

  Spotify_Manager()
  {
    retCode = -1;

    //Authenticate user
    get_auth();
  }

  void get_auth() async
  {
    /* Run callback server and authenticate with Spotify */

    //Run integrated server to handle Spotify callback
    run_server();

    //Load authentication URL
    String client = await load_env();
    authUrl = "https://accounts.spotify.com/authorize?client_id=";
    authUrl += client;
    authUrl += "&response_type=code&redirect_uri=http://localhost:8000";
    authUrl += "&scope=user-library-modify%20playlist-modify-private"; 
  }

  Future<String> load_env() async
  {
    /* Load Spotify developer client ID */

    //Load client ID
    String env = await rootBundle.loadString('assets/.client');
    int start = env.indexOf('\'') + 1;

    return env.substring(start, env.length - 1);
  }

  Future run_server() async
  {
    /* Run callback server for Spotify authentication */

    //Create server on locslhost
    var server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      8000,
    );

    //Wait for Spotify callback
    await for (HttpRequest request in server) {
      request.response..write('Validated!')..close();
      
      //If authenticated, store code
      if (request.uri.queryParameters.containsKey('code'))
      {
        accessCode = request.uri.queryParameters['code'];
        retCode = 1;
        server.close();
      }

      //Else, error
      else if (request.uri.queryParameters.containsKey('error'))
        retCode = 0;     

      //Update widget state
      wid.setState(() {}); 
    }
  }

}
