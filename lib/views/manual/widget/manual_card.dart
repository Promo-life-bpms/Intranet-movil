import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intranet_movil/model/manual.dart';
import 'package:intranet_movil/services/internet.dart';
import 'package:intranet_movil/utils/constants.dart';

class ManualCard extends StatefulWidget {
  const ManualCard({Key? key, required this.manualData}) : super(key: key);

  final List<ManualModel> manualData;

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 160.0,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: CachedNetworkImage(
                        imageUrl: ApiIntranetConstans.baseUrl +
                            widget.manualData[0].img,
                        errorWidget: (context, url, error) => const Image(
                            image: AssetImage("lib/assets/pdf.png")),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  widget.manualData[0].name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 5, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: ColorIntranetConstants.primaryColorNormal),
                    onPressed: () {
                      LaunchToInternet.launchURL(
                          ApiIntranetConstans.baseUrl +
                              widget.manualData[0].file.replaceAll(' ', '%20'),
                          context);
                    },
                    child: const Text('ABRIR'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
