import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

class Spotify_Manager {
  String authUrl;

  Spotify_Manager()
  {
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

    String env = await rootBundle.loadString('assets/.env');
    int start = env.indexOf('\'') + 1;

    return env.substring(start, env.length - 1);
  }

  Future run_server() async
  {
    /* Run callback server for Spotify authentication */
    
    var server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      8000,
    );

    await for (HttpRequest request in server) {
      request.response..write('Hello, world!')..close();
      print("GOT REQUEST");
    }
  }

}
