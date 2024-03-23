
import 'package:flutter/material.dart';
import 'package:dbase/page/login_page.dart';
import 'package:dbase/page/home_page.dart';
import 'package:dbase/page/add_product.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route to '/'
      routes: {
        '/': (context) => const LoginPage(), // LoginPage mapped to '/'
        '/home': (context) => const HomePage(), // HomePage mapped to '/home'
        '/add_product': (context) => AddProductPage(), // AddProductPage mapped to '/add_product'
      },
    );
  }
}
