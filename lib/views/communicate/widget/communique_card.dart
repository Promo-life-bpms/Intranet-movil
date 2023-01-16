import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intranet_movil/model/communique.dart';
import 'package:intranet_movil/services/internet.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:photo_view/photo_view.dart';

class CommuniqueCard extends StatefulWidget {
  const CommuniqueCard({Key? key, required this.commuiqueData})
      : super(key: key);

  final List<CommuniqueModel> commuiqueData;

  @override
  State<CommuniqueCard> createState() => _CommuniqueCardState();
}

class _CommuniqueCardState extends State<CommuniqueCard> {
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
          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
          child: Column(
            children: [
              InkWell(
                onDoubleTap: () {
                  if (Platform.isAndroid) {
                    if (widget.commuiqueData[0].image ==
                        "/img/communique.svg") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => PhotoView(
                                  imageProvider: const AssetImage(
                                      'lib/assets/communique.png'),
                                )),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => PhotoView(
                                  imageProvider: NetworkImage(
                                      ApiIntranetConstans.baseUrl +
                                          widget.commuiqueData[0].image),
                                )),
                      );
                    }
                  }
                },
                child: SizedBox(
                    width: double.infinity,
                    height: 320.0,
                    child: widget.commuiqueData[0].image ==
                            "/img/communique.svg"
                        ? const Image(
                            image: AssetImage('lib/assets/communique.png'),
                            fit: BoxFit.contain,
                          )
                        : Image(
                            image: NetworkImage(ApiIntranetConstans.baseUrl +
                                widget.commuiqueData[0].image),
                            fit: BoxFit.contain,
                          )),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.commuiqueData[0].title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.00,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SelectableLinkify(
                    onOpen: (link) => LaunchToInternet.launchURL(link.url),
                    text: widget.commuiqueData[0].description,
                    style: const TextStyle(
                      fontSize: 16.00,
                    ),
                    textAlign: TextAlign.justify,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
