import 'package:flutter/material.dart';
import 'package:ioc_chatbot/views/onboarding%20screens/onboarding_page.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), (){

      Navigator.push(
        context,
        PageTransition(
          curve: Curves.bounceOut,
          type: PageTransitionType.bottomToTop,
          child: OnBoardingPage(),
        ),
      );

      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnBoardingPage() ));


    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/Logo2.png'),
      ),
    );
  }
}
