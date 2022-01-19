import 'dart:convert';

class AppUserModel {
  final String? userId;
  final String? userName;
  final String? password;
  final String? timestamp;
  final String? photoUrl;
  final bool? isAdmin;
  final String? email;

  AppUserModel({
    this.userId,
    this.userName,
    this.password,
    this.timestamp,
    this.photoUrl,
    this.isAdmin,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'password': password,
      'timestamp': timestamp,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'email': email,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      userId: map['userId'],
      userName: map['userName'],
      password: map['password'],
      timestamp: map['timestamp'],
      photoUrl: map['photoUrl'],
      isAdmin: map['isAdmin'],
      email: map['email'],
    );
  }

  factory AppUserModel.fromDocument(doc) {
    return AppUserModel(
      userId: doc.data()["userId"],
      password: doc.data()["password"],
      userName: doc.data()["userName"],
      timestamp: doc.data()["timestamp"],
      email: doc.data()["email"],
      isAdmin: doc.data()["isAdmin"],
      photoUrl: doc.data()["photoUrl"],
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, userName: $userName, password: $password, timestamp: $timestamp, photoUrl: $photoUrl, isAdmin: $isAdmin, email: $email)';
  }

  String toJson() => json.encode(toMap());

  factory AppUserModel.fromJson(String source) =>
      AppUserModel.fromMap(json.decode(source));
}
