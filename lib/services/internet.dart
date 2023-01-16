import 'package:url_launcher/url_launcher.dart';

class LaunchToInternet {
  static launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}

class IOSLaunchToInternet {
  static launchURL(_url) async {
    if (await canLaunch(_url)) {
      await launch(_url, forceSafariVC: true);
    } else {
      throw 'Could not launch $_url';
    }
  }
}
