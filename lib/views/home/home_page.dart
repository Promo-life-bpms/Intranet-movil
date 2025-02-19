import 'package:flutter/material.dart';
import 'package:intranet_movil/model/birthday.dart';
import 'package:intranet_movil/model/communique.dart';
import 'package:intranet_movil/model/publication.dart';
import 'package:intranet_movil/model/user_model.dart';
import 'package:intranet_movil/services/api_birthday.dart';
import 'package:intranet_movil/services/api_communique.dart';
import 'package:intranet_movil/services/api_publications.dart';
import 'package:intranet_movil/services/api_user.dart';
import 'package:intranet_movil/services/fiirebase_settings.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/home/widget/birthday_home_builder.dart';
import 'package:intranet_movil/views/home/widget/birthday_title_card.dart';
import 'package:intranet_movil/views/home/widget/carousel_home_builder.dart';
import 'package:intranet_movil/views/home/widget/no_data_birthday_builder.dart';
import 'package:intranet_movil/views/home/widget/no_data_post_publication.dart';
import 'package:intranet_movil/views/home/widget/publication_builder.dart';
import 'package:intranet_movil/views/home/widget/publication_card.dart';
import 'package:intranet_movil/widget/navigation_drawer_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {Key? key,
      this.communiqueData,
      this.birthdayData,
      this.userData,
      this.publicationData})
      : super(key: key);

  final List<CommuniqueModel>? communiqueData;
  final List<BirthdayModel>? birthdayData;
  final List<UserModel>? userData;
  final List<PublicationModel>? publicationData;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  static const String _title = 'Inicio';
  late List<CommuniqueModel>? _communiqueModel = [];
  late List<BirthdayModel>? _brithdayModel = [];
  late List<UserModel>? _userlModel = [];
  late List<PublicationModel>? _publicationModel = [];

  static List<BirthdayModel>? _brithdayList = [];
  static List<UserModel>? _userList = [];
  static List<CommuniqueModel>? _communiqueList = [];

  static List<PublicationModel>? _publicationList = [];
  static List<PublicationModel>? _publicationListToLike = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLike = false;
  bool loadingComment = false;
  late String token = "";

  int initRange = 0;
  int limitRange = 8;

  @override
  void initState() {
    super.initState();
    // ignore: prefer_is_empty
    if (widget.userData == [] ||
        widget.userData == null ||
        widget.userData!.isEmpty) {
      _getData();
    } else {
      _userList = widget.userData;
    }

    // ignore: prefer_is_empty
    if (widget.birthdayData == [] ||
        widget.birthdayData == null ||
        widget.birthdayData!.isEmpty) {
      _getBirthdayData();
    } else {
      _brithdayList = widget.birthdayData;
    }

    // ignore: prefer_is_empty
    if (widget.communiqueData == [] ||
        widget.communiqueData == null ||
        widget.communiqueData!.isEmpty) {
      _getCommuniqueData();
    } else {
      _communiqueList = widget.communiqueData;
    }

    _getData();
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    String? _token = prefs.getString('token');
    if (_token != null || _token!.isNotEmpty) {
      token = _token;
    }
    _userlModel =
        (await ApiUserService().getUsers(_token.toString()))!.cast<UserModel>();
    _brithdayModel =
        (await ApiBrithdayService().getBrithday())!.cast<BirthdayModel>();
    _communiqueModel =
        (await ApiCommuniqueService().getCommunique())!.cast<CommuniqueModel>();
    _publicationModel =
        (await ApiPublicationService().getPublication(token.toString()))!
            .cast<PublicationModel>();

    setState(() {
      _userList = _userlModel;
      _brithdayList = _brithdayModel;
      _communiqueList = _communiqueModel;
      _publicationList = _publicationModel;
      _publicationListToLike = _publicationModel;

      FirebaseSettings()
          .configFirebasePersonalTopics(_userlModel![0].id.toString());
    });

    if (_userList != null || _userList!.isNotEmpty) {
      setState(() {});
      FirebaseSettings()
          .configFirebasePersonalTopics(_userList![0].id.toString());
    }

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getBirthdayData() async {
    _brithdayModel =
        (await ApiBrithdayService().getBrithday())!.cast<BirthdayModel>();

    setState(() {
      _brithdayList = _brithdayModel;
    });

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getCommuniqueData() async {
    _communiqueModel =
        (await ApiCommuniqueService().getCommunique())!.cast<CommuniqueModel>();

    setState(() {
      _communiqueList = _communiqueModel;
    });
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(userData: _userList),
        appBar: AppBar(
          title: const Text(_title),
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
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Colors.blue,
          strokeWidth: 3.0,
          onRefresh: () async {
            setState(() {
              _getData();
            });

            return Future<void>.delayed(const Duration(seconds: 3));
          },
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Container(
              color: ColorIntranetConstants.backgroundColorDark,
              child: Column(
                children: [
                  //Publicaciones
                  _userList == null || _userList!.isEmpty
                      ? const Column(
                          children: [
                            NoDataPublicationCard(),
                            Padding(padding: EdgeInsets.only(top: 8)),
                          ],
                        )
                      : Column(
                          children: [
                            PublicationCard(userData: _userList!),
                            const Padding(padding: EdgeInsets.only(top: 8)),
                          ],
                        ),

                  //Cumpleanos del mes
                  _brithdayList == null ||
                          _brithdayList!.isEmpty ||
                          _brithdayList == []
                      ? const Column(
                          children: [
                            BirthdayTitleCard(),
                            NoDataBirthdayHomeBuilder(),
                            Padding(padding: EdgeInsets.only(top: 8))
                          ],
                        )
                      : Column(
                          children: [
                            const BirthdayTitleCard(),
                            BirthdayHomeBuilder(birthdayData: _brithdayList!),
                            const Padding(padding: EdgeInsets.only(top: 8))
                          ],
                        ),
                  //Comunicados
                  // ignore: prefer_is_empty
                  _communiqueList == null ||
                          _communiqueList!.isEmpty ||
                          _communiqueList!.isEmpty
                      ? const Padding(padding: EdgeInsets.zero)
                      : Column(
                          children: [
                            CarouselHomeBuilder(
                                communiqueData: _communiqueList!),
                            const Padding(padding: EdgeInsets.only(bottom: 8))
                          ],
                        ),
                  //Publicaciones
                  _publicationList == null ||
                          _publicationList!.isEmpty ||
                          _publicationList == []
                      ? Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  "Actualizando publicaciones...",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                    width: 300,
                                    child: Lottie.asset(
                                        "lib/assets/fech_data.json")),
                              ),
                              const Padding(
                                padding:  EdgeInsets.all(8.0),
                                child: Text(
                                  "¿Problemas al cargar las publicaciones? prueba iniciar sesion nuevamente",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ))
                      : PublicationBuilder(
                          publicationData: _publicationList!
                              .getRange(0, limitRange)
                              .toList(),
                          publicationToLikeData: _publicationListToLike!
                              .getRange(0, limitRange)
                              .toList(),
                          userData: _userList!,
                          isLike: isLike,
                          token: token,
                          mainContext: context,
                        ),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8, left: 16, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        limitRange <= _publicationList!.length
                            ? ElevatedButton(
                                onPressed: ((() => paginatorNext())),
                                child: const Text("VER MAS"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorIntranetConstants.primaryColorDark,
                                    foregroundColor: Colors.white),
                              )
                            : ElevatedButton(
                                onPressed: (() {}),
                                child: const Text("VER MAS"),
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: ColorIntranetConstants
                                        .backgroundColorDark,
                                    backgroundColor: Colors.black),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  paginatorNext() {
    setState(() {
      if ((limitRange + 8) >= _publicationList!.length) {
        limitRange = _publicationList!.length - 1;
      } else {
        limitRange = limitRange + 8;
      }
    });
  }
}
