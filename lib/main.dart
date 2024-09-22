import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:my_news/authentication/login.dart';
import 'package:my_news/firebase_options.dart';
import 'package:my_news/newsprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: Duration.zero,
  ));

  try {
    bool fetchSuccess = await remoteConfig.fetchAndActivate();
    print('Remote config fetched and activated: $fetchSuccess');
    print('Country code: ${remoteConfig.getString('country_code')}');
    print('All Remote Config values: ${remoteConfig.getAll()}');
  } catch (e) {
    print('Error fetching remote config: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsProvider(),
      child: MaterialApp(
        title: 'MyNews',
        theme: ThemeData(
          primaryColor: Color(0xFF0C54BE),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthenticationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
