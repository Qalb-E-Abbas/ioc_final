// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:ioc_chatbot/both_apps.dart';
//
// class LoginUI extends StatelessWidget {
//   const LoginUI({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Icon(Icons.arrow_back_ios_outlined),
//                   ),
//                 ),
//                 Text("Login"),
//               ],
//             ),
//             SizedBox(
//               height: 50,
//             ),
//             Text("Login with one of the following"),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 38.0),
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => BothApps()));
//                     },
//                     child: Expanded(
//                       child: Container(
//                           color: Colors.green,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Icon(
//                               FontAwesomeIcons.google,
//                               color: Colors.blue,
//                             ),
//                           )),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: Colors.orange,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(Icons.exit_to_app),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: Colors.orange,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(Icons.exit_to_app),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: Colors.orange,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(Icons.exit_to_app),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 50,
//               width: 50,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(3),
//                   border: Border.all(color: Colors.black)),
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Image.asset(
//                   'assets/images/Chat.png',
//                   color: Colors.black,
//                   height: 60,
//                   width: 60,
//                 ),
//               ),
//             ),
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage('assets/images/featureImage.jpeg'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
