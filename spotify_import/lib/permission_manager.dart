import 'package:simple_permissions/simple_permissions.dart';
import 'dart:io' as IO;
import 'dart:async';

class Permission_Manager {
  /* Get user permissions */

  final Completer c = new Completer();

  Future get_permissions() async
  {

    //Android handler
    if (IO.Platform.isAndroid)
    {
        //Check for read permissions
        SimplePermissions.checkPermission(Permission.ReadExternalStorage).then((result)
        {
          //If granted
          if (result)
          {
            c.complete(true);
          }
          //Otherwise request them
          else
          {
            SimplePermissions.requestPermission(Permission.ReadExternalStorage).then((result)
            {
              // Determine if they were granted
              if (result == PermissionStatus.authorized)
              {
                c.complete(true);
              }
              else
              {
                IO.exit(0); //TODO - display a message
              }
            });
          }
        });
    }

    else
    {
      c.complete(true);
    }
    
    return c.future;
  }

}
