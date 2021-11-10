import 'package:get_storage/get_storage.dart';

class UserLocalData {
  String s = 'sd';
  final getStorageProference = GetStorage();

  // Future init() async => _preferences = await SharedPreferences.getInstance();

  // Future<bool> logOut() => _preferences.clear();

  Future logOut() => getStorageProference.erase();
  final _userModelString = 'USERMODELSTRING';
  final _uidKey = 'UIDKEY';
  final _isLoggedIn = "ISLOGGEDIN";
  final _emailKey = 'EMAILKEY';
  final _userNameKey = 'USERNAMEKEY';
  // final _phoneNumberKey = 'PhoneNumber';
  // final _imageUrlKey = 'IMAGEURLKEY';
  // final _password = 'PASSWORD';
  final _isAdmin = 'ISADMIN';

  //
  // Setters
  //
  Future setUserModel(String userModel) async =>
      getStorageProference.write(_userModelString, userModel);
  Future setUserEmail(String email) async =>
      getStorageProference.write(_emailKey, email);
  Future setUserName(String userName) async =>
      getStorageProference.write(_userNameKey, userName);

  Future setIsAdmin(bool isAdmin) async =>
      getStorageProference.write(_isAdmin, isAdmin);

  Future setUserUID(String uid) async =>
      getStorageProference.write(_uidKey, uid);

  Future setNotLoggedIn() async =>
      getStorageProference.write(_isLoggedIn, false);

  Future setLoggedIn(bool isLoggedIn) async =>
      getStorageProference.write(_isLoggedIn, isLoggedIn );

  //
  // Getters
  //
  bool getIsAdmin() => getStorageProference.read(_isAdmin);
  String getUserModel() => getStorageProference.read(_userModelString) ?? '';

  String getUserUIDGet() => getStorageProference.read(_uidKey) ?? '';
  bool isLoggedIn() => getStorageProference.read(_uidKey);
  String getUserEmail() => getStorageProference.read(_emailKey) ?? '';
  String getUserName() => getStorageProference.read(_userNameKey) ?? '';
}
