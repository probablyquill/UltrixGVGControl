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

//Placeholder action for unimplemented buttons.
void placeholderAction() {
  print("Placeholder Action Executed");
}

class SwitcherPanel extends StatelessWidget {
  const SwitcherPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

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
                        ControlButton(title: "SOURCES", action: placeholderAction,),
                        SizedBox(height: 10),
                        ControlButton(title: "DESTINATIONS", action: placeholderAction),
                      ],),
                    ),
                    // This should potentially be broken out into it's own component for readability.
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
                        ControlButton(title: "TAKE", action: placeholderAction,),
                        SizedBox(height: 10),
                        ControlButton(title: "CLEAR", action: placeholderAction,),
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

//Reusable button for TAKE / SOURCE / etc.
class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.title,
    required this.action,
  });

  final String title;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
      onPressed: () {
        action();
    }, 
    child: SizedBox(
      width: 105,
      height: 60,
      child: Center(child: Text(title)))
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
        //I believe it is best practice to update this to create an array of button objects 
        //to pass into the GridView instead of generating them here. TODO
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
