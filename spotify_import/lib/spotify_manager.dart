import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'spotify_widget.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'audio_fs.dart' as Audio_FS;

class Import_Options
{
  bool toPlaylist = false;
  bool toLibrary = true;
  String playlistName = "Imported Songs";
}

class Token
{
  /* Class containing token info that automatically refreshes */

  String accessToken;
  String refreshToken;
  int expTime;

  Token({this.accessToken, this.refreshToken, this.expTime});

  //TODO - Add Asynchronous timer that autorefreshes
}

class Spotify_Manager {
  String authUrl;
  String accessCode;
  int retCode;

  String callback = "http://localhost:8000";
  String scopes = "user-library-modify%20playlist-modify-private";

  String client;
  String secret;
  
  State<Spotify_Widget> wid;
  Audio_FS.Audio_Filesystem files;
  List<Audio_FS.Audio_File> notFound = new List<Audio_FS.Audio_File>();

  Token token;

  Spotify_Manager()
  {
    retCode = -1;

    //Authenticate user
    get_auth();
  }

  void get_auth() async
  {
    /* Run callback server and authenticate with Spotify */

    //Get Spotify API info
    client = await load_env("client");
    secret = await load_env("secret");

    //Run integrated server to handle Spotify callback
    run_server();

    //Load authentication URL
    authUrl = "https://accounts.spotify.com/authorize?client_id=" + client;
    authUrl += "&response_type=code";
    authUrl += "&redirect_uri=" + callback;
    authUrl += "&scope=" + scopes; 
  }

  Future<String> load_env(String param) async
  {
    /* Load Spotify developer client ID */

    String env = await rootBundle.loadString('assets/.client');

    //Load client ID
    if (param == "client")
    {
      int start = env.indexOf('\'') + 1;
      int end = env.indexOf('\n') - 2;
      
      return env.substring(start, end);
    }

    if (param == "secret")
    {
      int brk = env.indexOf('\n') + 1;
      int start = env.indexOf('\'', brk) + 1;
      int end = env.lastIndexOf('\'');

      return env.substring(start, end);
    }
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
        server.close();
        send_post();
      }

      //Else, error
      else if (request.uri.queryParameters.containsKey('error'))
        retCode = 0;     

      //Update widget state
      wid.setState(() {}); 
    }
  }

  void send_post() async
  {
    /* Post to Spotify server for final authentication */

    //Send Post request
    HTTP.Response response = await HTTP.post("https://accounts.spotify.com/api/token", 
      body: {"grant_type": "authorization_code", "code": accessCode, 
      "redirect_uri": callback, "client_id": client, "client_secret": secret}
    );

    //Check status 
    if (response.statusCode == 200)
    {
      //If valid, get body contents and create Token
      Map body = jsonDecode(response.body);
      token = new Token(accessToken: body["access_token"], refreshToken: body["refresh_token"], 
                        expTime: body["expires_in"]);

      //Update state to display imprt button
      retCode = 1;
    }

    else
      retCode = 0;

    //Update widget
    wid.setState(() {}); 
  }

  String build_search_query(String title, String artist)
  {
    /* Build a Spotify API search query */

    title = title.replaceAll(" ", "+");
    artist = artist.replaceAll(" ", "+");
    String queryStart = "https://api.spotify.com/v1/search?";
    queryStart += "q=" + "artist:" + artist + "%20track:" + title + "&type=track" + "&limit=1";

    return queryStart;
  }

  String parse_id(String raw_id)
  {
    /* Parse an id from a raw URI */

    int id_start = raw_id.lastIndexOf('/') + 1;
    String id = raw_id.substring(id_start);

    return id;
  }

  void add_by_ids(List<String> ids) async
  {
    /* Add tracks to saved music */
    String all_ids = ids.join(",");

    await HTTP.put("https://api.spotify.com/v1/me/tracks?ids=" + all_ids, 
                    headers: {"Authorization": "Bearer " + token.accessToken});
  }

  void import_songs() async
  {
    /* Import songs to Spotify */

    notFound.clear();
    List<String> ids = [];

    //For all selected songs
    for(Audio_FS.Audio_File song in files.selected)
    {
      //Query Spotify API for track ID
      String query = build_search_query(song.title, song.artist);
      HTTP.Response response = await HTTP.get(query, 
                                headers: {"Authorization": "Bearer " + token.accessToken});

      Map data = jsonDecode(response.body);
      List<dynamic> vals = data["tracks"]["items"];
      
      //If track found
      //TODO - Perform title and artist verification
      if (vals.length > 0)
      {
        String raw_id = vals[0]["href"].toString();
        String id = parse_id(raw_id);
        ids.add(id);
      }

      //If track not found, add to list to alert user
      else
        notFound.add(song);
    }

    //Import all found songs
    add_by_ids(ids); 
    
    //Update state to display imported tracks
    retCode = 2;
    wid.setState(() {});
  }
}
