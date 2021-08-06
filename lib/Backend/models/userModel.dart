class UserModel {
  String docID;
  String firstName;
  String lastName;
  String profilePic;
  String gender;
  String regNo;
  String subjectIDs;
  bool isOnline;
  String email;
  String semester;
  String role;
  String lastSeen;
  String password;
  String section;
  List subjects;
  List students;

  UserModel({
    this.docID,
    this.firstName,
    this.lastName,
    this.profilePic,
    this.gender,
    this.regNo,
    this.email,
    this.semester,
    this.password,
    this.role,
    this.isOnline,
    this.section,
    this.subjects,
    this.students,
    this.lastSeen,
    this.subjectIDs,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    docID = json['docID'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    profilePic = json['profilePic'];
    gender = json['gender'];
    regNo = json['regNo'];
    password = json['password'];
    isOnline = json['isOnline'];
    email = json['email'];
    semester = json['semester'];
    role = json['role'];
    students = json['students'];
    subjects = json['subjects'];
    subjectIDs = json['subjectIDs'];
    lastSeen = json['lastSeen'];
    section = json['section'];
  }

  Map<String, dynamic> toJson(String docID) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docID'] = docID;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['profilePic'] = this.profilePic;
    data['isOnline'] = this.isOnline;
    data['role'] = this.role;
    data['gender'] = this.gender;
    data['regNo'] = this.regNo;
    data['email'] = this.email;
    data['students'] = this.students;
    data['semester'] = this.semester;
    data['subjects'] = this.subjects;
    data['subjectIDs'] = this.subjectIDs;
    data['lastSeen'] = this.lastSeen;
    data['section'] = this.section;
    data['password'] = this.password;
    return data;
  }
}
