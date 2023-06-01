import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intranet_movil/model/request.dart';
import 'package:intranet_movil/services/api_request.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/request/modules/approved.dart';
import 'package:intranet_movil/views/request/modules/pending.dart';
import 'package:intranet_movil/views/request/modules/process.dart';
import 'package:intranet_movil/views/request/modules/rejected.dart';
import 'package:intranet_movil/views/request/new_request.dart';
import 'package:intranet_movil/widget/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestMainPage extends StatefulWidget {
  const RequestMainPage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<RequestMainPage> {
  late List<RequestModel>? _requestModel = [];
  late List<RequestModel>? _requestModel2 = [];
  late String _token = "";

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Stream<List<RequestModel>?> _request() async* {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      _requestModel2 = (await ApiRequestService().getRequest(token.toString()))!
          .cast<RequestModel>();
      yield _requestModel2;
    }
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null || token!.isNotEmpty) {
      _token = token;
    }

    _requestModel = (await ApiRequestService().getRequest(token.toString()))!
        .cast<RequestModel>();
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: ColorIntranetConstants.primaryColorLight,
          primaryColorLight: ColorIntranetConstants.primaryColorLight,
          primaryColorDark: ColorIntranetConstants.primaryColorDark,
          backgroundColor: ColorIntranetConstants.backgroundColorDark,
          hoverColor: ColorIntranetConstants.primaryColorLight,
          scaffoldBackgroundColor: ColorIntranetConstants.backgroundColorNormal,
          appBarTheme: const AppBarTheme(
              backgroundColor: ColorIntranetConstants.primaryColorLight)),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          drawer: const NavigationDrawerWidget(),
          appBar: AppBar(
            /* actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ChatPage()));
                  },
                  child: const Image(
                    image: AssetImage('lib/assets/chat.png'),
                  ),
                ),
              ),
            ], */
            bottom: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.white.withOpacity(0.3),
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    child: Text(StringIntranetConstants.requestPendingPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestProcessPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestApprovedPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestRejectedPage),
                  ),
                ]),
            title: const Text(StringIntranetConstants.requestPage),
          ),
          body: StreamBuilder(
              stream: _request(),
              builder: (context, AsyncSnapshot<List<RequestModel>?> snapshot) {
                if (snapshot.hasData) {
                  _requestModel = snapshot.data;

                  TabBarView(
                    children: [
                      PendingRequestPage(
                        requestModel: _requestModel
                            ?.where((i) =>
                                i.directManagerStatus == "Pendiente" &&
                                i.humanResourcesStatus == "Pendiente")
                            .toList(),
                        token: _token,
                        contextMain: context,
                      ),
                      ProcessRequestPage(
                          requestModel: _requestModel
                              ?.where((i) =>
                                  i.directManagerStatus == "Aprobada" &&
                                  i.humanResourcesStatus == "Pendiente")
                              .toList()),
                      ApprovedRequestPage(
                          requestModel: _requestModel
                              ?.where((i) =>
                                  i.directManagerStatus == "Aprobada" &&
                                  i.humanResourcesStatus == "Aprobada")
                              .toList()),
                      RejectedRequestPage(
                          requestModel: _requestModel
                              ?.where((i) =>
                                  i.directManagerStatus == "Rechazada" ||
                                  i.humanResourcesStatus == "Rechazada")
                              .toList()),
                    ],
                  );
                }
                return TabBarView(
                  children: [
                    PendingRequestPage(
                      requestModel: _requestModel
                          ?.where((i) =>
                              i.directManagerStatus == "Pendiente" &&
                              i.humanResourcesStatus == "Pendiente")
                          .toList(),
                      token: _token,
                      contextMain: context,
                    ),
                    ProcessRequestPage(
                        requestModel: _requestModel
                            ?.where((i) =>
                                i.directManagerStatus == "Aprobada" &&
                                i.humanResourcesStatus == "Pendiente")
                            .toList()),
                    ApprovedRequestPage(
                        requestModel: _requestModel
                            ?.where((i) =>
                                i.directManagerStatus == "Aprobada" &&
                                i.humanResourcesStatus == "Aprobada")
                            .toList()),
                    RejectedRequestPage(
                        requestModel: _requestModel
                            ?.where((i) =>
                                i.directManagerStatus == "Rechazada" ||
                                i.humanResourcesStatus == "Rechazada")
                            .toList()),
                  ],
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestPage()),
              );
            },
            backgroundColor: ColorIntranetConstants.primaryColorNormal,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
