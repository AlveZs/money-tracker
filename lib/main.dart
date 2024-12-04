import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_tracker/data/repository/money_tx/money_tx_repository_impl.dart';
import 'package:money_tracker/data/source/local/local_storage.dart';
import 'package:money_tracker/domain/repository/money_tx_repository.dart';
import 'package:money_tracker/presentation/home/pages/home.dart';
import 'package:money_tracker/common/widgets/styled_bottom_nav.dart';
import 'package:money_tracker/presentation/provider/money_tx_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/configs/app_theme.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  final localStorage = LocalStorageImpl(sharedPreferences: sharedPref);
  final repo = MoneyTxRepositoryImpl(localStorage: localStorage);
  runApp(MainApp(moneyTxRepo: repo));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.moneyTxRepo, super.key});

  final MoneyTxRepository moneyTxRepo;

  @override
  Widget build(BuildContext context) {
    const theme = CustomTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => MoneyTxProvider(
                  moneyTxRepository: moneyTxRepo,
                )..fetchMoneyTxs()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('pt'),
        ],
        theme: theme.toThemeData(),
        darkTheme: theme.toThemeDataDark(),
        themeMode: ThemeMode.dark,
        home: const Scaffold(
          body: SafeArea(child: HomePage()),
          bottomNavigationBar: StyledBottomNav(),
        ),
      ),
    );
  }
}
