import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:platform_info/platform_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppwriteConfigs {
  /// Client of Appwrite
  final Client client;

  /// Your database ID
  final String databaseId;

  /// Your collection ID
  final String collectionId;

  /// Prefix of the SharedPreferences to save the local data
  final String localPrefix;

  /// Print debug log
  final bool debugLog;

  /// Default values
  final Map<String, dynamic> defaultValues;

  /// Get current config
  Map<String, dynamic> get config => _config;
  final Map<String, dynamic> _config = {};

  Timer? _timer;

  /// Ensure the [fetch] is completed
  Future<void> get ensureFetched => _completer.future;
  final _completer = Completer<void>();

  AppwriteConfigs({
    required this.client,
    required this.databaseId,
    required this.collectionId,
    this.defaultValues = const {},
    this.localPrefix = 'AppwriteConfigs',
    this.debugLog = false,
  }) {
    _config.addAll(defaultValues);
  }

  /// Fetching data
  Future<void> fetch({
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(minutes: 60),
  }) async {
    if (_completer.isCompleted) return;

    final prefs = await SharedPreferences.getInstance();
    final localConfigs = prefs.getString(localPrefix);
    final localData = localConfigs == null
        ? <String, dynamic>{}
        : jsonDecode(localConfigs) as Map<String, dynamic>;
    _config.addAll(localData);
    await _fetch(timeout);
    _completer.complete();
    _fetchRepeat(timeout, interval);
  }

  void _fetchRepeat(Duration timeout, Duration interval) {
    _timer?.cancel();

    _timer = Timer.periodic(interval, (timer) {
      _print('Fetch interval');
      _fetch(timeout);
    });
  }

  Future<void> _fetch(Duration timeout) async {
    bool isTimeout = false;
    final databases = Databases(client);
    final data = await databases
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    )
        .timeout(
      timeout,
      onTimeout: () {
        isTimeout = true;
        return DocumentList(documents: [], total: 0);
      },
    );

    if (isTimeout) {
      _print('Out of time');
      return;
    }

    for (final e in data.documents) {
      String key = e.data['key'];
      String? value = e.data[platform.operatingSystem.name.toLowerCase()];
      value ??= e.data['default'];

      _config.addAll({key: value});
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(localPrefix, jsonEncode(_config));

    _print('Available configurations: $_config');
  }

  void _print(String log) {
    assert(() {
      // ignore: avoid_print
      if (debugLog) print('[Appwrite Config] $log');
      return true;
    }());
  }
}
