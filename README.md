# Spotify Import App
### Author: Peter Swanson
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) 
[![Flutter](https://img.shields.io/badge/Flutter-1.0-green.svg)](https://flutter.io/) 
[![Simple Permissions](https://img.shields.io/badge/Simple%20Permissions-0.1.9-green.svg)](https://pub.dartlang.org/packages/simple_permissions)
[![http](https://img.shields.io/badge/http-0.12.0-green.svg)](https://pub.dartlang.org/packages/http)
[![Webview](https://img.shields.io/badge/Webview-0.3.0+2-green.svg)](https://pub.dartlang.org/packages/flutter_webview_plugin)

## Background:
It's hard to manage jumping between music stored on my phone and on my Spotify. I've set out to build a cross platform mobile application to automatically add my stored music to a Spotify playlist.

<b>This application is a work in progress.</b>

## TODO List:
### Spotify API Access
- Perform a more robust title and artist verification on collected songs

### Error Handling
- Display error page if user denies read privileges rather than exiting
- Perform verifications on all HTTP requests to ensure transactions successful
- Fix keyboard issues with iOS webview

### Compatibility 
- Fit webview to devices of different sizes

## Requirements:
### Flutter Plugins:
- Simple Permissions
  - https://pub.dartlang.org/packages/simple_permissions
- http
  - https://pub.dartlang.org/packages/http
- Webview Plugin
  - https://pub.dartlang.org/packages/flutter_webview_plugin

### Flutter Assets:
- assets/.client
  
  Contains your Spotify client ID and secret ID in the following form:
  ```
  SPOTIFY_CLIENT='YOUR_CLIENT_ID'
  SPOTIFY_SECRET='YOUR_SECRET_ID'
  ```
