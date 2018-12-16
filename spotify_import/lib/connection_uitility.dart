import 'package:http/http.dart' as HTTP;
import 'dart:async';

class Connection_Manager {
  bool isConnected = false;
  bool isCompleted = false;
  bool inProgress = false;

  void test_connect(Function update) async
  {
    /* Determine if connected to the internet */

    try
    {
      HTTP.get("https://www.google.com/").then((response)
      {
        isCompleted = true;

        if (response.statusCode == 200)
          isConnected = true;

        else
          isConnected = false;

        update();
      });
    }
    catch (e)
    {
      isConnected = false;
      update();
    }
  }
}