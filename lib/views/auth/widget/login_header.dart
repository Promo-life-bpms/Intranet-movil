import 'package:flutter/material.dart';

class LoginHeader extends StatefulWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  State<LoginHeader> createState() => _LoginHeaderState();
}

class _LoginHeaderState extends State<LoginHeader> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            SizedBox(
              width: 60,
              height: 50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("lib/assets/promolife.png")),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("lib/assets/bhtrade.png")),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("lib/assets/trademarket.png")),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("lib/assets/promodreams.png")),
              ),
            )
          ],
        ));
  }
}
