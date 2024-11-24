import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDatabase {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> hashPassword(String password) async {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> registerUser(String username, String password) async {
    final prefs = await _prefs;
    final users = prefs.getStringList('users') ?? [];

    if (users.contains(username)) {
      return false;
    }

    users.add(username);
    final hashedPassword = await hashPassword(password);
    await prefs.setString('password_$username', hashedPassword);
    await prefs.setStringList('users', users);
    return true;
  }

  Future<bool> validateUser(String username, String password) async {
    final prefs = await _prefs;
    final hashedPassword = prefs.getString('password_$username');

    if (hashedPassword == null) {
      return false;
    }

    final inputHash = await hashPassword(password);
    return inputHash == hashedPassword;
  }
}
