import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dphoc/services/google_sheets_service.dart';  // Import the service
import 'package:dphoc/services/connectivity_service.dart';
import 'package:dphoc/views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // No need to pass the apiKey and spreadsheetId here anymore
        Provider<GoogleSheetsService>(
          create: (_) => GoogleSheetsService(),  // Just instantiate without API Key and spreadsheetId
        ),
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Phone Directory',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 61, 111, 219)),fontFamily: '4_3D',
          useMaterial3: true,
        ),
        initialRoute: '/',  // Define the initial route
        home: const HomeView(),
      ),
    );
  }
}
