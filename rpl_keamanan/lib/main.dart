import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependency_injector.dart';
import 'screens/home_screen.dart';
import 'repositories/user_repository.dart';
import 'repositories/post_repository.dart';

void main() {
  final injector = DependencyInjector();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: injector.userRepository),
        Provider<PostRepository>.value(value: injector.postRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Repository App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}
