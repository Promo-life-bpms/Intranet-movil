import 'package:flutter/material.dart';
import 'package:intranet_movil/services/api_auth.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/auth/widget/login_header.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class LoginForm extends StatefulWidget {
  LoginForm({Key? key, this.validator}) : super(key: key);
  String? validator;

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  String _errorMessage = '';

  Future<void> submitForm() async {
    setState(() {
      _errorMessage = '';
    });
    bool result = await Provider.of<AuthProvider>(context, listen: false)
        .login(_email, _password);
    if (result == false) {
      setState(() {
        _errorMessage =
            'Usuario o contraseña no valida, verifique que los datos sean correctos';
      });
    }
  }

  bool boolTrue = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 320.0,
                  decoration: const BoxDecoration(
                    color: ColorIntranetConstants.primaryColorLight,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 600.0,
                  decoration: const BoxDecoration(
                    color: ColorIntranetConstants.backgroundColorNormal,
                  ),
                  child: Align(
                    alignment: const Alignment(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 550.0,
                        child: OverflowBox(
                            child: Column(
                          children: [
                            const LoginHeader(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Center(
                                      child: Text(
                                        "Iniciar sesión",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 40)),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                          hintText: 'Ingrese su email',
                                          icon: Icon(
                                            Icons.mail,
                                          )),
                                      validator: (value) => value!.isEmpty
                                          ? 'Este campo no puede estar vacio'
                                          : null,
                                      onSaved: (value) =>
                                          _email = value.toString(),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 16)),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Ingrese su contraseña',
                                        icon: Icon(
                                          Icons.lock,
                                        ),
                                      ),
                                      obscureText: true,
                                      validator: (value) => value!.isEmpty
                                          ? 'Este campo no puede estar vacio'
                                          : null,
                                      onSaved: (value) =>
                                          _password = value.toString(),
                                    ),
                                    Text(
                                      _errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          child: const Text('INICIAR SESIÓN'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ColorIntranetConstants
                                                      .primaryColorNormal),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _formKey.currentState!.save();
                                              submitForm();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
