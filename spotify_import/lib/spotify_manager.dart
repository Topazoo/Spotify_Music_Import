import 'package:flutter/services.dart' show rootBundle;

class Spotify_Manager {
  String authUrl;

  Spotify_Manager()
  {
    get_auth_url();
  }

  void get_auth_url() async
  {
    String client = await load_env();
    authUrl = "https://accounts.spotify.com/authorize?client_id=";
    authUrl += client;
    authUrl += "&response_type=code&redirect_uri=http://10.0.2.2:8080";
    authUrl += "&scope=user-library-modify%20playlist-modify-private"; 
  }

  Future<String> load_env() async
  {

    String env = await rootBundle.loadString('assets/.env');
    int start = env.indexOf('\'') + 1;

    return env.substring(start, env.length -1);
  }

}
