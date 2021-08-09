class PostModel {

  String docID;
  String postText;
  String postImage;
  String postImageName;
  String section;
  String advID;
  String subject;
  List users;
  String advImage;
  String time;
  int sortTime;


  PostModel(
      {this.docID,
      this.postText,
      this.postImage,
      this.postImageName,
      this.section,
      this.advID,
      this.subject,
      this.users,
      this.advImage,
      this.time,
      this.sortTime});

  PostModel.fromJson(Map<String, dynamic> json) {
    docID = json['docID'];
    postText = json['postText'];
    postImage = json['postImage'];
    postImageName = json['postImageName'];
    advID = json['advID'];
    subject = json['subject'];
    section = json['section'];
    users = json['users'];
    advImage = json['advImage'];
    time = json['time'];
    sortTime = json['sortTime'];
  }

  Map<String, dynamic> toJson(String docID) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docID'] = docID;
    data['postText'] = this.postText;
    data['postImage'] = this.postImage;
    data['postImageName'] = this.postImageName;
    data['advID'] = this.advID;
    data['subject'] = this.subject;
    data['section'] = this.section;
    data['users'] = this.users;
    data['advImage'] = this.advImage;
    data['time'] = this.time;
    data['sortTime'] = this.sortTime;
    return data;
  }
}
