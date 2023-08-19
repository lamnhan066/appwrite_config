# Appwrite Config

Remote configuration for Appwrite.

## Usage

``` dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite_config/appwrite_config.dart';

final appwriteHelper = AppwriteHelper.instance;

class AppwriteHelper {
  static AppwriteHelper instance = AppwriteHelper._();

  AppwriteHelper._();

  late final Databases databases;
  late final AppwriteConfigs configs;

  void initial() {
    Client client = Client();
    client.setEndpoint('https://cloud.appwrite.io/v1').setProject('backupr');

    databases = Databases(client);
    configs = AppwriteConfigs(
      client: client,
      databaseId: 'main',
      collectionId: 'configuration',
      debugLog: true,
      defaultValues: {
        'Update.LatestVersion': '1.0.0',
        'Setting.MaxDownloadNumber': 50,
        'Update.BannedVersion': <String>['<=1.0.0'],
        'Update.OnlyShowDialogWhenBanned': false,
      },
    );
  }

  Future<void> fetchConfigs() =>
      configs.fetch(timeout: const Duration(seconds: 5));
}
```

Fetch data:

``` dart
appwriteHelper.initial();
await appwriteHelper.fetch();
```

Get data:

``` dart
appwriteHelper.configs.getString('Update.LatestVersion');
```
