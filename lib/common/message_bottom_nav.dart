import 'package:flutter/material.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';

import 'horizontal_sized_box.dart';

class MessageBottomNav extends StatefulWidget {
  const MessageBottomNav({Key key}) : super(key: key);

  @override
  _MessageBottomNavState createState() => _MessageBottomNavState();
}

class _MessageBottomNavState extends State<MessageBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FrontEndConfigs.blueTextColor),
                    color: Colors.white),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Type a message'),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: FrontEndConfigs.blueTextColor,
                            ),
                            onPressed: () {})
                      ],
                    )),
              ),
              HorizontalSpace(10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FrontEndConfigs.blueTextColor,
                ),
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
