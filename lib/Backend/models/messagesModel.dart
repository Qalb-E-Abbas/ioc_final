class MessagesModel {
  String senderName;
  String sendID;
  String docID;
  int time;
  String messageBody;
  bool isRead;

  MessagesModel(
      {this.senderName,
      this.sendID,
      this.docID,
      this.isRead,
      this.time,
      this.messageBody});

  MessagesModel.fromJson(Map<String, dynamic> json) {
    senderName = json['senderName'];
    sendID = json['sendID'];
    docID = json['docID'];
    isRead = json['isRead'];
    time = json['time'];
    messageBody = json['messageBody'];
  }

  Map<String, dynamic> toJson(String docID) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['senderName'] = this.senderName;
    data['sendID'] = this.sendID;
    data['docID'] = docID;
    data['time'] = this.time;
    data['isRead'] = this.isRead;
    data['messageBody'] = this.messageBody;
    return data;
  }
}
