import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/Logics/userProvider.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/end_drawer.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/frontEndConfigs.dart';
import 'package:ioc_chatbot/Backend/models/chatModel.dart';
import 'package:ioc_chatbot/Backend/models/messagesModel.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/authServices.dart';
import 'package:ioc_chatbot/Backend/services/chatServices.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/elements/customOnlineDot.dart';
import 'package:ioc_chatbot/views/elements/searchField.dart';
import 'package:ioc_chatbot/views/elements/searchFieldBackArrow.dart';
import 'package:ioc_chatbot/views/students/chat_messages_screen.dart';
import 'package:ioc_chatbot/views/students/loginView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../contactList.dart';

class ChatList extends StatefulWidget {
  final String id;

  const ChatList(this.id);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  List<UserModel> searchedUsers = [];
  bool initialized = false;
  int i = 0;
  bool isSearchingAllow = false;

  void _searchedOrders(String val) async {
    print("HI USerList");
    var usersList = Provider.of<UserProvider>(context, listen: false);
    searchedUsers.clear();
    print("HI UsersList : ${usersList.getUsers.length}");
    for (var i in usersList.getUsers) {
      var lowerCaseString = i.firstName.toString().toLowerCase() +
          " " +
          i.lastName.toLowerCase() +
          i.regNo.toLowerCase();

      var defaultCase =
          i.firstName.toString() + " " + i.lastName.toString() + i.regNo;

      if (lowerCaseString.contains(val) || defaultCase.contains(val)) {
        searchedUsers.add(i);
      } else {
        setState(() {
          isSearched = true;
        });
      }
    }
    setState(() {});
  }

  bool isSearched = false;
  UserModel userModel = UserModel();
  UserModel advModel = UserModel();
  UserModel sendToUser;
  bool isDone = false;
  List<ChatModel> chatModel = [];
  AdvisorChatServices _advisorChatServices = AdvisorChatServices();
  UserServices _userServices = UserServices();
  AuthServices _authServices = AuthServices.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isSearchingAllow
            ? SearchFieldBackArrow(
                onTap: () {
                  setState(() {
                    searchedUsers.clear();
                    isSearchingAllow = false;
                    isSearched = false;
                  });
                },
              )
            : Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: Icon(Icons.menu, size: 28, color: Colors.black),
                  );
                },
              ),
        centerTitle: true,
        title: !isSearchingAllow
            ? Text(
                "Chat",
              )
            : SearchField(onChanged: (val) {
                setState(() {
                  _searchedOrders(val);
                });
              }),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: !isSearchingAllow
                ? IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isSearchingAllow = true;
                      });
                    },
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              onPressed: () async {
                storage.clear();

                await _authServices.signOut();
                UserLoginStateHandler.saveUserLoggedInSharedPreference(false);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                    (route) => false);
              },
            ),
          ),
        ],
      ),
      endDrawer: EndDrawer(),
      body: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!initialized) {
              var items =
                  storage.getItem(BackEndConfigs.userDetailsLocalStorage);
              var adv =
                  storage.getItem(BackEndConfigs.advisorDetailsLocalStorage);

              if (items != null) {
                print(items);
                userModel = UserModel(
                  regNo: items['regNo'],
                  semester: items['semester'],
                  email: items['email'],
                  firstName: items['firstName'],
                  lastName: items['lastName'],
                  docID: items['docID'],
                  profilePic: items['profilePic'],
                  gender: items['gender'],
                );
              }
              if (adv != null) {
                print(items);
                advModel = UserModel(
                  regNo: adv['regNo'],
                  semester: adv['semester'],
                  email: adv['email'],
                  firstName: adv['firstName'],
                  lastName: adv['lastName'],
                  docID: adv['docID'],
                  profilePic: adv['profilePic'],
                  gender: adv['gender'],
                );
              }

              initialized = true;
            }
            return snapshot.data == null
                ? LoadingWidget()
                : _getUI(context, userModel);
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ContactList()));
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _userServices.changeOnlineStatus(
        userModel: UserModel(docID: widget.id), isOnline: false);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement dispose

    _userServices.changeOnlineStatus(
        userModel: UserModel(docID: widget.id), isOnline: true);
    super.initState();
  }

  Widget _getUI(BuildContext context, UserModel model) {
    var usersProvider = Provider.of<UserProvider>(context);
    print(model.docID);
    return model == null
        ? Container()
        : SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 170),
                    child: Divider(
                      thickness: 1,
                      height: 1,
                      color: FrontEndConfigs.blueTextColor,
                    ),
                  ),
                  StreamProvider.value(
                    value: _advisorChatServices.getChatList(context,
                        docID: model.docID),
                    builder: (context, child) {
                      return context.watch<List<ChatModel>>() == null
                          ? LoadingWidget()
                          : context.watch<List<ChatModel>>().length != 0
                              ? searchedUsers.isEmpty
                                  ? isSearched == true
                                      ? Center(child: Text("No Data"))
                                      : Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.65,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: FrontEndConfigs
                                              .authFieldBackgroundColor,
                                          child: ListView.separated(
                                              separatorBuilder: (ctx, index) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 5),
                                                  child: Divider(
                                                    thickness: 1,
                                                    height: 1,
                                                    color: FrontEndConfigs
                                                        .blueTextColor,
                                                  ),
                                                );
                                              },
                                              itemCount: context
                                                  .watch<List<ChatModel>>()
                                                  .length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder: (ctx, index) {
                                                return StreamProvider.value(
                                                  value: _userServices
                                                      .fetchStudentsData(context
                                                          .read<
                                                              List<
                                                                  ChatModel>>()[
                                                              index]
                                                          .chatID
                                                          .replaceAll("_", "")
                                                          .replaceAll(
                                                              model.docID, "")),
                                                  builder: (c, child) {
                                                    return c.watch<
                                                                UserModel>() ==
                                                            null
                                                        ? LoadingWidget()
                                                        : StreamProvider.value(
                                                            value: _advisorChatServices
                                                                .getUnreadMessagesCount(
                                                                    context,
                                                                    context
                                                                        .read<
                                                                            List<
                                                                                ChatModel>>()[
                                                                            index]
                                                                        .chatID,
                                                                    userModel),
                                                            builder:
                                                                (chatCountContext,
                                                                    child) {
                                                              List userList =
                                                                  [];
                                                              userList.add(
                                                                  UserModel(
                                                                firstName: c
                                                                    .watch<
                                                                        UserModel>()
                                                                    .firstName,
                                                                lastName: c
                                                                    .watch<
                                                                        UserModel>()
                                                                    .lastName,
                                                                regNo: c
                                                                    .watch<
                                                                        UserModel>()
                                                                    .regNo,
                                                              ));
                                                              print(context
                                                                  .watch<
                                                                      List<
                                                                          ChatModel>>()
                                                                  .length);
                                                              if (usersProvider
                                                                      .getUsers
                                                                      .length <
                                                                  context.watch<List<ChatModel>>().length) if (c.watch<
                                                                      UserModel>() !=
                                                                  null)
                                                                usersProvider.setUsers(UserModel(
                                                                    docID: c
                                                                        .watch<
                                                                            UserModel>()
                                                                        .docID,
                                                                    isOnline: c
                                                                        .watch<
                                                                            UserModel>()
                                                                        .isOnline,
                                                                    profilePic: c
                                                                        .watch<
                                                                            UserModel>()
                                                                        .profilePic,
                                                                    firstName: c
                                                                        .watch<
                                                                            UserModel>()
                                                                        .firstName,
                                                                    lastName:
                                                                        c.watch<UserModel>().lastName,
                                                                    regNo: context.watch<List<ChatModel>>()[index].lastMessage,
                                                                    role: context.watch<List<ChatModel>>()[index].chatID));

                                                              return c.watch<UserModel>() ==
                                                                          null ||
                                                                      chatCountContext
                                                                              .watch<List<MessagesModel>>() ==
                                                                          null
                                                                  ? LoadingWidget()
                                                                  : Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          ChatModel
                                                                              cModel =
                                                                              context.read<List<ChatModel>>()[index];
                                                                          setState(
                                                                              () {});

                                                                          Navigator.of(context)
                                                                              .push(MaterialPageRoute(builder: (builder) => ChatMessageScreen(userID: userModel.docID, messages: chatCountContext.watch<List<MessagesModel>>(), chatID: cModel.chatID)));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              FrontEndConfigs.authFieldBackgroundColor,
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Card(
                                                                              elevation: 4,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              child: ListTile(
                                                                                leading: Stack(
                                                                                  children: [
                                                                                    CircleAvatar(
                                                                                      backgroundImage: c.watch<UserModel>().profilePic == "" ? AssetImage('assets/images/placeholderUser.png') : NetworkImage(c.watch<UserModel>().profilePic ?? ""),
                                                                                      radius: 30,
                                                                                    ),
                                                                                    c.watch<UserModel>().isOnline
                                                                                        ? Positioned(
                                                                                            bottom: 0,
                                                                                            right: 3,
                                                                                            child: customOnlineDot(Colors.green),
                                                                                          )
                                                                                        : Positioned(
                                                                                            bottom: 0,
                                                                                            right: 3,
                                                                                            child: customOnlineDot(Colors.grey),
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                                subtitle: Text(context.watch<List<ChatModel>>()[index].lastMessage),
                                                                                title: Text(c.watch<UserModel>().firstName + " " + c.watch<UserModel>().lastName),
                                                                                trailing: chatCountContext.watch<List<MessagesModel>>().length != 0
                                                                                    ? Container(
                                                                                        height: 24,
                                                                                        width: 24,
                                                                                        decoration: BoxDecoration(shape: BoxShape.circle, color: FrontEndConfigs.blueTextColor),
                                                                                        child: Center(
                                                                                          child: DynamicFontSize(
                                                                                            label: chatCountContext.read<List<MessagesModel>>().length.toString(),
                                                                                            color: Colors.white,
                                                                                            fontSize: 16,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Container(
                                                                                        height: 24,
                                                                                        width: 24,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                            },
                                                          );
                                                  },
                                                );
                                              }),
                                        )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: searchedUsers.length,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          ChatMessageScreen(
                                                              userID: userModel
                                                                  .docID,
                                                              messages: [],
                                                              chatID:
                                                                  searchedUsers[
                                                                          i]
                                                                      .role)));
                                            },
                                            child: Container(
                                              color: FrontEndConfigs
                                                  .authFieldBackgroundColor,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Center(
                                                child: Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: ListTile(
                                                    leading: Stack(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage: searchedUsers[
                                                                          i]
                                                                      .profilePic ==
                                                                  ""
                                                              ? AssetImage(
                                                                  'assets/images/placeholderUser.png')
                                                              : NetworkImage(
                                                                  searchedUsers[
                                                                              i]
                                                                          .profilePic ??
                                                                      ""),
                                                          radius: 30,
                                                        ),
                                                        searchedUsers[i]
                                                                .isOnline
                                                            ? Positioned(
                                                                bottom: 0,
                                                                right: 3,
                                                                child: customOnlineDot(
                                                                    Colors
                                                                        .green),
                                                              )
                                                            : Positioned(
                                                                bottom: 0,
                                                                right: 3,
                                                                child: customOnlineDot(
                                                                    Colors
                                                                        .grey),
                                                              ),
                                                      ],
                                                    ),
                                                    subtitle: Text(
                                                        searchedUsers[i].regNo),
                                                    title: Text(searchedUsers[i]
                                                            .firstName +
                                                        " " +
                                                        searchedUsers[i]
                                                            .lastName),
                                                    // trailing: chatCountContext
                                                    //             .watch<
                                                    //                 List<
                                                    //                     MessagesModel>>()
                                                    //             .length !=
                                                    //         0
                                                    //     ? Container(
                                                    //         height: 24,
                                                    //         width: 24,
                                                    //         decoration: BoxDecoration(
                                                    //             shape: BoxShape
                                                    //                 .circle,
                                                    //             color: FrontEndConfigs
                                                    //                 .blueTextColor),
                                                    //         child: Center(
                                                    //           child:
                                                    //               DynamicFontSize(
                                                    //             label: chatCountContext
                                                    //                 .read<
                                                    //                     List<
                                                    //                         MessagesModel>>()
                                                    //                 .length
                                                    //                 .toString(),
                                                    //             color: Colors
                                                    //                 .white,
                                                    //             fontSize: 16,
                                                    //           ),
                                                    //         ),
                                                    //       )
                                                    //     : Container(
                                                    //         height: 24,
                                                    //         width: 24,
                                                    //         decoration:
                                                    //             BoxDecoration(
                                                    //           shape: BoxShape
                                                    //               .circle,
                                                    //         ),
                                                    //       ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                              : Center(child: Text("No Data"));
                    },
                  )
                ],
              ),
            ),
          );
  }
}
