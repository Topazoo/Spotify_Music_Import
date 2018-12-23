import 'package:flutter/material.dart';
import 'dart:io' as IO;

Rect get_device_rect(BuildContext context)
{
    if (IO.Platform.isAndroid)
    {
        Rect newRect = new Rect.fromLTWH(0.0, 80.0, 
            MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 135);
        
        return newRect;
    }

    else
    {
        //TODO - Correct sizing for different iPhones
        Rect newRect = new Rect.fromLTWH(0.0, 100.0, 
            MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 185);
        
        return newRect;      
    }
}