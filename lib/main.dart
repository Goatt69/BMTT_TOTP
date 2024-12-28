import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'screens/login_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    shadcn.ShadcnApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
        theme: shadcn.ThemeData(
          colorScheme: const shadcn.ColorScheme(
            brightness: Brightness.light,
            background: Color(0xffffffff),
            foreground: Color(0xff020817),
            card: Color(0xffffffff),
            cardForeground: Color(0xff020817),
            popover: Color(0xffffffff),
            popoverForeground: Color(0xff020817),
            primary: Color(0xff2462eb),
            primaryForeground: Color(0xfff8fafc),
            secondary: Color(0xfff1f5f9),
            secondaryForeground: Color(0xff0f1729),
            muted: Color(0xfff1f5f9),
            mutedForeground: Color(0xff65748b),
            accent: Color(0xfff1f5f9),
            accentForeground: Color(0xff0f1729),
            destructive: Color(0xffef4343),
            destructiveForeground: Color(0xfff8fafc),
            border: Color(0xff020817),
            input: Color(0xffe1e7ef),
            ring: Color(0xff2462eb),
            chart1: Color(0xffe76e50),
            chart2: Color(0xff2a9d90),
            chart3: Color(0xff274754),
            chart4: Color(0xffe8c468),
            chart5: Color(0xfff4a462),
          ),
          radius: 0.6,
        ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facebook-like Interface',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.white),
      ),
      home: const LoginScreen(),
    );
  }
}


