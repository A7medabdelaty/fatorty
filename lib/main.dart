import 'package:bike_rental_pos/screens/splash_screen.dart';
import 'package:bike_rental_pos/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'blocs/auth/auth_bloc.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Builder(
        builder: (context) => BlocProvider(
          create: (_) => AuthBloc(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          child: MaterialApp(
            title: 'Bike Rental POS',
            theme: ThemeData(
              primaryColor: const Color(0xFF4FAAFF),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4FAAFF),
                brightness: Brightness.light,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''),
            ],
            locale: const Locale('ar', ''),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
