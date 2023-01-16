import 'package:flutter/material.dart';
import 'package:intranet_movil/model/access.dart';
import 'package:intranet_movil/services/internet.dart';
import 'package:intranet_movil/utils/constants.dart';

class AccessCard extends StatefulWidget {
  const AccessCard({Key? key, required this.accessData}) : super(key: key);

  final List<AccessData> accessData;

  @override
  State<AccessCard> createState() => _AccessCardState();
}

class _AccessCardState extends State<AccessCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 160.0,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image(
                        image: AssetImage(widget.accessData[0].accImage),
                      )),
                ),
                Text(
                  widget.accessData[0].accName,
                  style: const TextStyle(fontSize: 16.00),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 5, left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              ColorIntranetConstants.primaryColorNormal),
                      onPressed: () {
                        LaunchToInternet.launchURL(
                            widget.accessData[0].accLink);
                      },
                      child: const Text('ABRIR'),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
