import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ioc_chatbot/both_apps.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: 'Chitti The Robot',
              body: 'Hello Sir, How Can I Help You?',
              image: buildImage('assets/images/onboard1.jpg'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'You\'re just one step away',
              body: 'Available right at your fingerprints',
              image: buildImage('assets/images/screen1.png'),
              decoration: getPageDecoration(),
            ),


          ],
          done: GestureDetector(
              onTap: () {

                Navigator.of(context).pushReplacement(

                    PageRouteBuilder(
                        transitionDuration: const Duration(seconds: 1),
                        pageBuilder: (_, animation, __){

                          animation = CurvedAnimation(parent:
                          animation, curve: Curves.easeOut);


                          return ScaleTransition(
                            scale: animation,
                            child: BothApps(),
                          );
                        })
                );
              },

              child: Text('Go', style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blueTextColor,))),
          onDone: () => goToHome(context),
          showSkipButton: true,
          skip: Text('Skip', style: TextStyle(
              color: AppColors.blueTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold

          ),),
          onSkip: () => goToHome(context),
          next: Icon(Icons.fast_forward, color: AppColors.buttonColor),
          dotsDecorator: getDotDecoration(),
          onChange: (index) => print('Page $index selected'),
          globalBackgroundColor: Colors.white,
          skipFlex: 0,
          nextFlex: 0,
          // isProgressTap: false,
          // isProgress: false,
          showNextButton: true,
          // freeze: true,
          // animationDuration: 1000,
        ),
      );

  void goToHome(context) =>
      Navigator.of(context).pushReplacement(

          PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1),
              pageBuilder: (_, animation, __){

                animation = CurvedAnimation(parent:
                animation, curve: Curves.easeOut);


                return ScaleTransition(
                  scale: animation,
                  child: BothApps(),
                );
              })
      );

  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  DotsDecorator getDotDecoration() =>
      DotsDecorator(
        color: Color(0xFFBDBDBD),
        //activeColor: Colors.orange,
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );

  PageDecoration getPageDecoration() =>
      PageDecoration(
        titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, ),
        bodyTextStyle: TextStyle(fontSize: 25),
        descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.all(24),
        pageColor: Colors.white,
      );
}
