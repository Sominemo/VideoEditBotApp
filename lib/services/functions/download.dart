import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Download {
  static bool permissionReady;
  static String localPath;

  static void init() async {
    permissionReady = false;

    permissionReady = await _checkPermission();

    localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(localPath);
    final hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  static Future<bool> _checkPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static Future<String> _findLocalPath() async {
    final directory = defaultTargetPlatform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> startDownload(Uri url, {String fileName}) async {
    await init();

    return FlutterDownloader.enqueue(
      url: url.toString(),
      savedDir: localPath,
      showNotification: true,
      openFileFromNotification: true,
      fileName: fileName,
    );
  }
}
