class ChatModel {
  String chatID;
  List<String> users;
  String lastMessage;
  int time;

  ChatModel({this.chatID, this.users, this.time, this.lastMessage});

  ChatModel.fromJson(Map<String, dynamic> json) {
    chatID = json['chatID'];
    time = json['time'];
    lastMessage = json['lastMessage'];
    users = json['users'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatID'] = this.chatID;
    data['users'] = this.users;
    data['lastMessage'] = this.lastMessage;
    data['time'] = DateTime.now().microsecondsSinceEpoch;
    return data;
  }
}
