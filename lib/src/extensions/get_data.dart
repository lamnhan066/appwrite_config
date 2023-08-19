import 'dart:convert';

import 'package:appwrite_config/appwrite_config.dart';

extension GetDataEx on AppwriteConfigs {
  String getString(String key) {
    return config[key].toString();
  }

  int getInt(String key) {
    final value = config[key];
    if (value is int) return value;
    return int.parse(value.toString());
  }

  double getDouble(String key) {
    final value = config[key];
    if (value is double) return value;
    return double.parse(value.toString());
  }

  Map<String, dynamic> getMap(String key) {
    final value = config[key];
    if (value is Map<String, dynamic>) return value;
    return jsonDecode(value.toString());
  }

  bool getBool(String key) {
    final value = config[key];
    if (value is bool) return value;
    return jsonDecode(value.toString()) as bool;
  }

  List<T> getList<T>(String key) {
    final value = config[key];
    if (value is List<T>) return value;
    return jsonDecode(value.toString()).cast<T>();
  }
}
