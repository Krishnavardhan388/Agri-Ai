import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/domain/user_role.dart';

class LocalStorageService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUid = 'user_uid';
  static const String _keyName = 'user_name';
  static const String _keyPhone = 'user_phone';
  static const String _keyRole = 'user_role';
  static const String _keyLocation = 'user_location';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  UserRole get savedRole {
    final roleStr = _prefs.getString(_keyRole) ?? 'farmer';
    try {
      return UserRole.values.byName(roleStr);
    } catch (_) {
      return UserRole.farmer;
    }
  }

  UserModel? getSavedUser() {
    if (!isLoggedIn) return null;
    final uid = _prefs.getString(_keyUid) ?? 'offline_user';
    final name = _prefs.getString(_keyName) ?? '';
    final phone = _prefs.getString(_keyPhone) ?? '';
    final location = _prefs.getString(_keyLocation) ?? '';
    return UserModel(
      uid: uid,
      name: name,
      phone: phone,
      role: savedRole,
      location: location,
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveUserSession(UserModel user) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUid, user.uid);
    await _prefs.setString(_keyName, user.name);
    await _prefs.setString(_keyPhone, user.phone);
    await _prefs.setString(_keyRole, user.role.name);
    await _prefs.setString(_keyLocation, user.location);
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUid);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyPhone);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyLocation);
  }
}
