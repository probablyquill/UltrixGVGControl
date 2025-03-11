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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 36, 69, 255)),
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
          SwitcherPanel(),
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                          onPressed: () {
                        
                        }, 
                        child: SizedBox(
                          width: 105,
                          height: 60,
                          child: Center(child: Text("SOURCES")))
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                          onPressed: () {
                        
                        }, 
                        child: SizedBox(
                          width: 105,
                          height: 60,
                          child: Center(child: Text("DESTINATIONS")))
                        ),
                      ],),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text("Destination:"),
                                  SizedBox(width: 10),
                                  Text("DEST"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Source:"),
                                  SizedBox(width: 10),
                                  Text("SRC"),
                                ],
                              ),
                          ],),
                          ButtonGrid()
                        ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                          
                          onPressed: () {
                        
                        }, 
                        child: SizedBox(
                          width: 105,
                          height: 60,
                          child: Center(child: Text("TAKE")))
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                          onPressed: () {
                        
                        }, 
                        child: SizedBox(
                          width: 105,
                          height: 60,
                          child: Center(child: Text("CLEAR")))
                        ),
                      ],),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
    );
  }
}

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final int crossAxis = 16;

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(1),
      shrinkWrap: true,
      crossAxisCount: crossAxis,
      childAspectRatio: (width / height) / 1.99,
      children: [
        for (var i = 0; i < appState.buttonList.length; i++)
          Padding(
            padding: const EdgeInsets.all(3),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              onPressed: () {
                  print(i);
            }, child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text("${i + 1}"))),
          )
        ],
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
