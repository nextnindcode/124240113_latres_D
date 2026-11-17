import 'package:shared_preferences/shared_preferences.dart';

class RegistrationService {
  static const String _registeredUsersKey = 'registeredUsers';

  // Mengambil semua username yang sudah didaftarkan.
  static Future<List<String>> getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_registeredUsersKey) ?? [];
  }

  // Mengecek apakah username sudah pernah didaftarkan.
  static Future<bool> isUsernameRegistered(String username) async {
    final users = await getRegisteredUsers();

    return users.any((user) => user.toLowerCase() == username.toLowerCase());
  }

  // Menyimpan username baru ke SharedPreferences.
  static Future<bool> register(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_registeredUsersKey) ?? [];

    final alreadyExists = users.any(
      (user) => user.toLowerCase() == username.toLowerCase(),
    );

    if (alreadyExists) {
      return false;
    }

    users.add(username);
    await prefs.setStringList(_registeredUsersKey, users);

    return true;
  }
}
