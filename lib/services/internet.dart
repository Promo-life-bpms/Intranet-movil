import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchToInternet {
  static launchURL(_url, context) async {
    // ignore: deprecated_member_use
    if (await canLaunch(_url)) {
      // ignore: deprecated_member_use
      await launch(_url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ocurriò un error, intenta nuevamente")));
    }
  }
}

class IOSLaunchToInternet {
  static launchURL(_url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(_url)) {
      // ignore: deprecated_member_use
      await launch(_url, forceSafariVC: true);
    } else {
      throw 'Could not launch $_url';
    }
  }
}
