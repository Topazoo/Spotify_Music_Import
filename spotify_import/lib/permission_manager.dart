import 'package:simple_permissions/simple_permissions.dart';
import 'dart:io' as IO;
import 'dart:async';

class Permission_Manager {
  /* Get user permissions */

  Future<bool> get_permissions() async
  {
    //Android handler
    if (IO.Platform.isAndroid)
    {
      //Check for read permissions
      await SimplePermissions.checkPermission(Permission.ReadExternalStorage).then((result) async
      {
        //If granted
        if (result)
          return true;

        //Otherwise request them
        else
        {
          await SimplePermissions.requestPermission(Permission.ReadExternalStorage).then((result)
          {
            // Determine if they were granted
            if (result == PermissionStatus.authorized)
              return true;

            else
              IO.exit(0); //TODO - display a message
          });
        }
      });
    }
    
    //iPhone permissions are automatic
    return true;
  }

}
