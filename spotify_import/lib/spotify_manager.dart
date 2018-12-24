import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:flutter/material.dart';
import 'spotify_widget.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as HTTP;
import 'audio_fs.dart' as Audio_FS;

class Import_Options
{
  bool toPlaylist = false;
  bool toLibrary = true;
  String playlistName = "Imported Songs";
  final textController = new TextEditingController();
}

class Token
{
  /* Class containing token info that automatically refreshes */

  String accessToken;
  String refreshToken;
  int expTime;

  String client;
  String secret;

  Timer timer;

  Token(String accessToken, String refreshToken, int expTime, String client, String secret)
  {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.expTime = expTime;
    this.client = client;
    this.secret = secret;
    this.timer = new Timer(new Duration(seconds: expTime - 1), refresh); 
  }

  void refresh() async
  {
    /* Refresh the auth token when it expires */

    //Get new token
    HTTP.Response response = await HTTP.post("https://accounts.spotify.com/api/token", 
      body: {"grant_type": "refresh_token", "refresh_token": refreshToken, 
             "client_id": client, "client_secret": secret}
    );

    //Store token info
    Map resp_JSON = jsonDecode(response.body);
    this.expTime = resp_JSON["expires_in"];
    this.accessToken = resp_JSON["access_token"];

    //Restart timer
    this.timer = new Timer(new Duration(seconds: this.expTime - 1), refresh);
  }
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
  Import_Options options = new Import_Options();

  Spotify_Manager()
  {
    retCode = -1;

    //Authenticate user
    get_auth();
  }

  void handle_auth_android(String client, String secret)
  {
    //Run integrated server to handle Spotify callback
    run_server();
  }

  void handle_auth_iOS() async
  {
    print("Handling iOS authentication");
    run_server();
    const platform = const MethodChannel('flutter.io.media/get_auth');
    final String auth_info = await platform.invokeMethod('get_auth', {"client":client, 
                                                                      "secret":secret,
                                                                      "callback":callback,
                                                                      "auth_url":authUrl});
    print(auth_info);
  }

  void get_auth() async
  {
    /* Run callback server and authenticate with Spotify */

    //Get Spotify API info
    client = await load_env("client");
    secret = await load_env("secret");

    //Load authentication URL
    authUrl = "https://accounts.spotify.com/authorize?client_id=" + client;
    authUrl += "&response_type=code";
    authUrl += "&redirect_uri=" + callback;
    authUrl += "&scope=" + scopes; 

    if(Platform.isAndroid)
      handle_auth_android(client, secret);
  }

  Future<String> load_env(String param) async
  {
    /* Load Spotify developer client ID */

    String env = await rootBundle.loadString('assets/.client');

    //Load client ID
    if (param == "client")
    {
      int start = env.indexOf('\'') + 1;
      int end = env.indexOf('\n') - 1; //TODO - Check on Android
      
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
      
      print(request.uri.queryParameters);

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
      token = new Token(body["access_token"], body["refresh_token"], 
                        body["expires_in"], client, secret);

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

  String build_playlist_JSON()
  {
    /* Create the JSON required for a new playlis */

    String name;

    if (options.textController.text.length > 0)
      name = options.textController.text;
    else
      name = options.playlistName;

    Map playlist = {};
    playlist["name"] = name;
    playlist["public"] = false;
    playlist["description"] = "Created with Spotify Import";

    return json.encode(playlist);
  }

  List<List<String>> package(List<String> all, int size)
  {
    /* Package a list in chunks of a set size */

    List<List<String>> package = [];

    //Loop adding lists of 50 to final list
    int lastEnd = 0;
    while(all.length - lastEnd > size)
    {
      Iterable<String> currIt = all.getRange(lastEnd, size + lastEnd);
      List<String> curr = currIt.toList();

      package.add(curr);
      lastEnd += curr.length;
    }

    //Add any leftover elements
    int rem = all.length - lastEnd;
    if(rem > 0)
    {
      Iterable<String> currIt = all.getRange(lastEnd, rem + lastEnd);
      List<String> curr = currIt.toList();
      package.add(curr);
    }

    return package;
  }

  Future package_and_add(List<List<String>> idsandUris) async
  {
    /* Split the Ids and URI's into chunks and add them */

    List<List<String>> p_ids = package(idsandUris[0], 50);
    List<List<String>> p_uris = package(idsandUris[1], 100);

    if(options.toLibrary)
    {
      for(List<String> p_id in p_ids)
      {
        Map id_map = {};
        id_map["ids"] = p_id;

        //Add all packaged IDs to library
        HTTP.put("https://api.spotify.com/v1/me/tracks", 
                  headers: {"Authorization": "Bearer " + token.accessToken,
                            "Content-Type": "application/json"},
                  body: jsonEncode(id_map)
                );
      }
    }

    if(options.toPlaylist)
    {
      //Get user ID
      HTTP.Response resp = await HTTP.get("https://api.spotify.com/v1/me",
                                          headers: {"Authorization": "Bearer " + token.accessToken});
      Map respJSON = jsonDecode(resp.body);
      String uID = respJSON["id"];

      //Create playlist
      resp = await HTTP.post("https://api.spotify.com/v1/users/" + uID +"/playlists",
                      headers: {"Authorization": "Bearer " + token.accessToken,
                                "Content-Type": "application/json"},
                      body: build_playlist_JSON());
      
      //Get playlist ID
      respJSON = jsonDecode(resp.body);
      String playlistID = respJSON["id"];
      
      //Add all packaged URIs to playlist
      for(List<String> p_uri in p_uris)
      {
        Map uri_map = {};
        uri_map["uris"] = p_uri;

        //Add tracks to playlist
        await HTTP.post("https://api.spotify.com/v1/playlists/" + playlistID +"/tracks", 
                        headers: {"Authorization": "Bearer " + token.accessToken,
                                  "Content-Type": "application/json"},
                        body: jsonEncode(uri_map)
                       );
      }
    }

  }

  void import_songs() async
  {
    /* Import songs to Spotify */

    notFound.clear();
    List<List<String>> idsandURIs = [[],[]];

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
        //Get track details
        String raw_id = vals[0]["href"].toString();
        String uri = vals[0]["uri"].toString();
        String id = parse_id(raw_id);
        
        //Add URIs and IDs
        idsandURIs[0].add(id);
        idsandURIs[1].add(uri);
      }

      //If track not found, add to list to alert user
      else
        notFound.add(song);
    }

    //Import all found songs
    await package_and_add(idsandURIs);
    
    //Update state to display imported tracks
    retCode = 2;
    wid.setState(() {});
  }
}
