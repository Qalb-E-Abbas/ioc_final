import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/auth_state.dart';
import 'package:ioc_chatbot/Logics/userProvider.dart';
import 'package:ioc_chatbot/common/dynamicFontSize.dart';
import 'package:ioc_chatbot/common/end_drawer.dart';
import 'package:ioc_chatbot/common/loading_widget.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/configurations/AppColors.dart';
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
import 'package:ioc_chatbot/views/teachers/studentsList.dart';
import 'package:ioc_chatbot/views/teachers/teacher_loginView.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class TeacherChatList extends StatefulWidget {
  final UserModel userModel;

  TeacherChatList(this.userModel);

  @override
  _TeacherChatListState createState() => _TeacherChatListState();
}

class _TeacherChatListState extends State<TeacherChatList> {
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);
  UserModel advModel = UserModel();
  bool initialized = false;

  AdvisorChatServices _advisorChatServices = AdvisorChatServices();
  UserServices _userServices = UserServices();
  bool isDone = false;
  AuthServices _authServices = AuthServices.instance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _userServices.changeOnlineStatus(
        userModel: UserModel(docID: widget.userModel.docID), isOnline: false);
    _userServices.updateLastSeen(
        userModel: UserModel(docID: widget.userModel.docID),
        time: "${DateTime.now().hour} : ${DateTime.now().minute}");
    super.dispose();
  }

  List<UserModel> searchedUsers = [];
  bool isSearchingAllow = false;
  bool isSearched = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isSearchingAllow
            ? SearchFieldBackArrow(
                onTap: () {
                  Provider.of<UserProvider>(context, listen: false).clearList();
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
            ? DynamicFontSize(label: 'chats',)
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
              onPressed: () {
                UserLoginStateHandler.saveTeacherLoggedInSharedPreference(false);
                storage.clear();
                _authServices.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherLoginView()),
                    (route) => false);
              },
            ),
          ),
        ],
      ),
      endDrawer: EndDrawer(),
      body: _getUI(context, widget.userModel),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.backgroundScreen,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => StudentsList()));
        },
        child: Icon(Icons.chat, color: Colors.black,),
      ),
    );
  }

  Widget _getUI(BuildContext _, UserModel _model) {
    var usersProvider = Provider.of<UserProvider>(context);
    if (_model != null) if (!isDone) {
      _userServices.changeOnlineStatus(
          userModel: UserModel(docID: _model.docID), isOnline: true);

      isDone = true;
      setState(() {});
    }

    print("I am ${usersProvider.getUsers.length}");
    return _model == null
        ? LoadingWidget()
        : StreamProvider.value(
            value:
                _advisorChatServices.getChatList(context, docID: _model.docID),

            builder: (context, child) {
              return context.watch<List<ChatModel>>() == null
                  ? LoadingWidget()
                  : context.watch<List<ChatModel>>().length != 0
                      ? searchedUsers.isEmpty
                          ? isSearched == true
                              ? Center(child: Text("No Data"))
                              : ListView.builder(
                                  itemCount:
                                      context.watch<List<ChatModel>>().length,
                                  itemBuilder: (_, i) {
                                    return StreamProvider.value(
                                      value: _userServices.fetchStudentsData(
                                          context
                                              .read<List<ChatModel>>()[i]
                                              .chatID
                                              .replaceAll("_", "")
                                              .replaceAll(_model.docID, "")),
                                      builder: (ct, child) {
                                        return ct.watch<UserModel>() == null
                                            ? LoadingWidget()
                                            : StreamProvider.value(
                                                value: _advisorChatServices
                                                    .getUnreadMessagesCount(
                                                        context,
                                                        context
                                                            .read<
                                                                List<
                                                                    ChatModel>>()[
                                                                i]
                                                            .chatID,
                                                        UserModel(
                                                            docID:
                                                                _model.docID)),
                                                builder:
                                                    (chatCountContext, child) {
                                                  List userList = [];
                                                  userList.add(UserModel(
                                                    firstName: ct
                                                        .watch<UserModel>()
                                                        .firstName,
                                                    lastName: ct
                                                        .watch<UserModel>()
                                                        .lastName,
                                                    regNo: ct
                                                        .watch<UserModel>()
                                                        .regNo,
                                                  ));
                                                  print(context
                                                      .watch<List<ChatModel>>()
                                                      .length);
                                                  if (usersProvider
                                                          .getUsers.length <
                                                      context
                                                          .watch<
                                                              List<ChatModel>>()
                                                          .length) if (ct.watch<UserModel>() !=
                                                      null)
                                                    usersProvider.setUsers(UserModel(
                                                        docID: ct
                                                            .watch<UserModel>()
                                                            .docID,
                                                        isOnline: ct
                                                            .watch<UserModel>()
                                                            .isOnline,
                                                        profilePic: ct
                                                            .watch<UserModel>()
                                                            .profilePic,
                                                        firstName: ct
                                                            .watch<UserModel>()
                                                            .firstName,
                                                        lastName: ct
                                                            .watch<UserModel>()
                                                            .lastName,
                                                        regNo: context
                                                            .watch<List<ChatModel>>()[
                                                                i]
                                                            .lastMessage,
                                                        role: context
                                                            .watch<
                                                                List<ChatModel>>()[i]
                                                            .chatID));
                                                  return chatCountContext.watch<
                                                              List<
                                                                  MessagesModel>>() ==
                                                          null
                                                      ? LoadingWidget()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              ChatModel model =
                                                                  context.read<
                                                                      List<
                                                                          ChatModel>>()[i];
                                                              setState(() {});

                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (builder) =>

                                                                          ChatMessageScreen(
                                                                            chatID:
                                                                                model.chatID,
                                                                            messages:
                                                                                chatCountContext.watch<List<MessagesModel>>(),
                                                                            userID:
                                                                                widget.userModel.docID,
                                                                          )));
                                                            },
                                                            child: Container(
                                                              color: AppColors
                                                                  .authFieldBackgroundColor,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Center(
                                                                child: Card(
                                                                  elevation: 4,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  child:
                                                                      ListTile(
                                                                    leading:
                                                                        Stack(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundImage: ct.watch<UserModel>().profilePic == ""
                                                                              ? AssetImage('assets/images/placeholderUser.png')
                                                                              : NetworkImage(ct.watch<UserModel>().profilePic ?? ""),
                                                                          radius:
                                                                              30,
                                                                        ),
                                                                        ct.watch<UserModel>().isOnline
                                                                            ? Positioned(
                                                                                bottom: 5,
                                                                                right: 2,
                                                                                child: customOnlineDot(Colors.green),
                                                                              )
                                                                            : Positioned(
                                                                                bottom: 5,
                                                                                right: 2,
                                                                                child: customOnlineDot(Colors.grey),
                                                                              ),
                                                                      ],
                                                                    ),
                                                                    subtitle: Text(context
                                                                        .read<
                                                                            List<
                                                                                ChatModel>>()[
                                                                            i]
                                                                        .lastMessage),
                                                                    title: Text(ct
                                                                        .watch<
                                                                            UserModel>()
                                                                        .firstName),
                                                                    trailing: chatCountContext.watch<List<MessagesModel>>().length !=
                                                                            0
                                                                        ? Container(
                                                                            height:
                                                                                24,
                                                                            width:
                                                                                24,
                                                                            decoration:
                                                                                BoxDecoration(shape: BoxShape.circle, color: AppColors.blueTextColor),
                                                                            child:
                                                                                Center(
                                                                              child: DynamicFontSize(
                                                                                label: chatCountContext.read<List<MessagesModel>>().length.toString(),
                                                                                color: Colors.white,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            height:
                                                                                24,
                                                                            width:
                                                                                24,
                                                                            decoration:
                                                                                BoxDecoration(
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
                                  })
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
                                                      userID: _model.docID,
                                                      messages: [],
                                                      chatID: searchedUsers[i]
                                                          .role)));
                                    },
                                    child: Container(
                                      color: AppColors
                                          .authFieldBackgroundColor,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
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
                                                          searchedUsers[i]
                                                                  .profilePic ??
                                                              ""),
                                                  radius: 30,
                                                ),
                                                searchedUsers[i].isOnline
                                                    ? Positioned(
                                                        bottom: 0,
                                                        right: 3,
                                                        child: customOnlineDot(
                                                            Colors.green),
                                                      )
                                                    : Positioned(
                                                        bottom: 0,
                                                        right: 3,
                                                        child: customOnlineDot(
                                                            Colors.grey),
                                                      ),
                                              ],
                                            ),
                                            subtitle:
                                                Text(searchedUsers[i].regNo),
                                            title: Text(
                                                searchedUsers[i].firstName +
                                                    " " +
                                                    searchedUsers[i].lastName),
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
          );
  }
}
