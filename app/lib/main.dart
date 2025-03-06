import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class AppState extends ChangeNotifier {
  var buttonList = <int>[];

  void generateButtos() {
    for (int i = 0; i < 144; i++) {
        buttonList.add(i);
    }
    notifyListeners();
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'buttonTest',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    if (appState.buttonList.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: () {
            appState.generateButtos();
          }, 
          child: Text("Hit me"),
          ),
      );
    }
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            Text("Test"),
            for (var i in appState.buttonList)
              SwitcherButton(i: i),
          ],
        ),
      ),
    );
  }

}

class SwitcherButton extends StatelessWidget {
  SwitcherButton({
    super.key,
    required this.i,
  });

  final int i;
  late final int displayInt = i + 1;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("Button Pressed: $displayInt");
      }, 
      child: Text("Number $displayInt"),
      );
  }
}
