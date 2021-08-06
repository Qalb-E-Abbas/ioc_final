class SubjectModel {
  String subjectID;
  String subjectName;

  SubjectModel({this.subjectID, this.subjectName});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    subjectID = json['subjectID'];
    subjectName = json['subjectName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subjectID'] = this.subjectID;
    data['subjectName'] = this.subjectName;
    return data;
  }
}
