import 'package:flutter/material.dart';
import 'package:intranet_movil/model/user_model.dart';
import 'package:intranet_movil/services/api_user.dart';
import 'package:intranet_movil/services/auth.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/auth/login_page.dart';
import 'package:intranet_movil/views/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => AuthProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyApp> {
  late List<UserModel>? _userModel = [];
  late String? _token = "";

  late String? email;
  late String? fullname;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userModel =
        (await ApiUserService().getUsers(_token.toString()))!.cast<UserModel>();
    if (_userModel != null || _userModel!.isNotEmpty) {
      await prefs.setString('fullname', _userModel![0].fullname);
      await prefs.setString('email', _userModel![0].email);
      await prefs.setString(
          'photo', ApiIntranetConstans.baseUrl + _userModel![0].photo);
    }
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Login',
        theme: ThemeData(
            primaryColor: ColorIntranetConstants.primaryColorLight,
            primaryColorLight: ColorIntranetConstants.primaryColorLight,
            primaryColorDark: ColorIntranetConstants.primaryColorDark,
            backgroundColor: ColorIntranetConstants.backgroundColorDark,
            hoverColor: ColorIntranetConstants.primaryColorLight,
            appBarTheme: const AppBarTheme(
                backgroundColor: ColorIntranetConstants.primaryColorLight)),
        home: Scaffold(
            body: _userModel == null || _userModel!.isEmpty
                ? Center(child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      switch (auth.isAuthenticated) {
                        case true:
                          return const HomePage();
                        default:
                          return const LoginForm();
                      }
                    },
                  ))
                : const HomePage()));
  }
}
