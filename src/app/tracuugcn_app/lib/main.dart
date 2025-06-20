import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa màn hình ở chế độ dọc (không cho phép xoay màn hình)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final languageService = LanguageService();
  await languageService.loadLanguage();
  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;

  const MyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: languageService,
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tra Cứu GCN',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.light,
              ),
            ),
            locale: languageService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
