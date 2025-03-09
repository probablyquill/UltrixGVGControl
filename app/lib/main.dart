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
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.control_camera_outlined), 
                label: Text("Switcher")),
              NavigationRailDestination(
                icon: Icon(Icons.settings), 
                label: Text("Settings")),
          ],
          selectedIndex: 0,),
          VerticalDivider(thickness: 1, width: 1,),
          Expanded(child: SwitcherPanel()),
          ],
        )
    );
  }

}

class SwitcherPanel extends StatelessWidget {
  const SwitcherPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Center(
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(10),
        crossAxisCount: 16,
        childAspectRatio: (width / height) / 1.8,
        children: [
          for (var i = 0; i < appState.buttonList.length; i++)
            Padding(
              padding: const EdgeInsets.all(1.5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                onPressed: () {
                    print(i);
              }, child: Text("${i + 1}")),
            )
        ],)
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
