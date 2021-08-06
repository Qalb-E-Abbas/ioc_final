import 'package:flutter/material.dart';
import 'package:ioc_chatbot/Logics/userProvider.dart';
import 'package:ioc_chatbot/configurations/back_end_configs.dart';
import 'package:ioc_chatbot/Backend/models/userModel.dart';
import 'package:ioc_chatbot/Backend/services/user_services.dart';
import 'package:ioc_chatbot/views/elements/searchField.dart';
import 'package:ioc_chatbot/views/students/chat_messages_screen.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'elements/loading_widget.dart';
import 'elements/searchFieldBackArrow.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  UserServices _userServices = UserServices();
  final LocalStorage storage = new LocalStorage(BackEndConfigs.loginLocalDB);

  bool initialized = false;
  UserModel userModel = UserModel();
  List<UserModel> searchedUsers = [];
  int i = 0;
  bool isSearchingAllow = false;

  void _searchedOrders(String val) async {
    var usersList = Provider.of<UserProvider>(context, listen: false);
    usersList.getUsers.map((e) {
      print("HI USERLIST : ${e.toJson(e.docID)}");
    }).toList();
    searchedUsers.clear();
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
              : IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 17,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          centerTitle: true,
          title: !isSearchingAllow
              ? Text(
                  "Contact List",
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
          ],
        ),
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
                    subjects: items['subjects'],
                  );
                }

                initialized = true;
              }
              return snapshot.data == null
                  ? LoadingWidget()
                  : _getUI(context, userModel);
            }));
  }

  Widget _getUI(BuildContext context, UserModel _userModel) {
    var usersProvider = Provider.of<UserProvider>(context);
    return StreamProvider.value(
      value: _userServices.fetchAllTeachers(_userModel),
      builder: (context, child) {
        if (usersProvider
            .getUsers.isEmpty) if (context.watch<List<UserModel>>() != null)
          usersProvider.setUsersList(context.watch<List<UserModel>>());

        return context.watch<List<UserModel>>() == null
            ? Center(child: LoadingWidget())
            : context.watch<List<UserModel>>().length != 0
                ? searchedUsers.isEmpty
                    ? isSearched == true
                        ? Center(child: Text("No Data"))
                        : ListView.builder(
                            itemCount: context.watch<List<UserModel>>().length,
                            itemBuilder: (ctxt, i) {
                              return ListTile(
                                onTap: () {
                                  UserModel d =
                                      context.read<List<UserModel>>()[i];
                                  print(userModel.docID);

                                  setState(() {});
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => ChatMessageScreen(
                                          sendByID: userModel.docID,
                                          sendToID: d.docID)));
                                },
                                title: Text(context
                                        .watch<List<UserModel>>()[i]
                                        .firstName +
                                    " " +
                                    context
                                        .watch<List<UserModel>>()[i]
                                        .lastName),
                                subtitle: Text(
                                    context.watch<List<UserModel>>()[i].regNo),
                              );
                            })
                    : ListView.builder(
                        itemCount: searchedUsers.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            onTap: () {
                              UserModel d = searchedUsers[i];
                              setState(() {});
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ChatMessageScreen(
                                      sendByID: userModel.docID,
                                      sendToID: d.docID)));
                            },
                            title: Text(searchedUsers[i].firstName +
                                " " +
                                searchedUsers[i].lastName),
                            subtitle: Text(searchedUsers[i].regNo),
                          );
                        })
                : Center(child: Text("No Data"));
      },
    );
  }
}
