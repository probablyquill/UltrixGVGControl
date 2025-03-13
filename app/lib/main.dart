import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// ChangeNotifier will manage all recieved router info.
class AppState extends ChangeNotifier {
  // true = Source Select, false = Dest Select
  bool panelMode = true;
  int selectedButton = -1;
  int activeSource = 100; //Normaled for testing purposes, this should start at -1.
  int activeDest = -1;

  // Will need to be set by the response from the router.
  String activeSrcName = "";
  String activeDestName = "";

  var buttonList = <int>[];

  void generateButtos() {
    for (int i = 0; i < 144; i++) {
        buttonList.add(i);
    }
    notifyListeners();
  }

  void updateSelected(int button) {
    selectedButton = button;
    print("Selected $button");
    print("Panel Mode: ${(panelMode) ? "Source" : "Dest"}");
    print("Active Source: $activeSource");
    print("Active Dest: $activeDest");
    notifyListeners();
  }

  void setPanelType(bool type) {
    panelMode = type;
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

// SwitcherPanel module to be placed inside the HomePage.
class SwitcherPanel extends StatelessWidget {
  const SwitcherPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

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
                        ControlButton(title: "SOURCES", action: (){appState.setPanelType(true);},),
                        SizedBox(height: 10),
                        ControlButton(title: "DESTINATIONS", action: (){appState.setPanelType(false);}),
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

// Reusable button for TAKE / SOURCE / etc.
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
    var color = Theme.of(context).colorScheme.primaryContainer;
    var appState = context.watch<AppState>();

    // Need to find a cleaner way to do this but it works for now.
    // Covers the needed swapping for SOURCES and DESTINATIONS while
    // leaving TAKE and CLEAR alone.

    // panelMode is true if SRC is selected, false if DEST is selected.
    if (title == "SOURCES" && appState.panelMode) {
      color = Theme.of(context).colorScheme.onPrimaryContainer;
    } 
    if (title == "DESTINATIONS" && !appState.panelMode) {
      color = Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
      onPressed: () {
        action();
    }, 
    child: SizedBox(
      width: 110,
      height: 60,
      child: Center(child: Text(title)))
    );
  }
}

// Houses just the generated grid of buttons for the SwitcherPanel
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
        // I believe it is best practice to update this to create an array of button objects 
        // to pass into the GridView instead of generating them here. Will fix later.
        for (var i = 0; i < appState.buttonList.length; i++)
          Padding(
            padding: const EdgeInsets.all(3),
            child: PanelButton(number: i),
          ),
        ],
      );
  }
}

// Broken out to its own class in preperation to later change how buttons are generated.
class PanelButton extends StatelessWidget {
  const PanelButton({
    super.key,
    required this.number,
  });

  final int number;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    int status = 0;

    // Detect what the selected button should be based on the panel mode.
    int active = (appState.panelMode) ? appState.activeSource : appState.activeDest;
    // Checks to see if the active value is the same as the selected
    if (appState.selectedButton == number) status = (active == number) ? 2 : 1;

    // Determine button color based on the status.
    var color = Theme.of(context).colorScheme.primaryContainer;
    if (status == 1) {
      color = Theme.of(context).colorScheme.tertiaryContainer;
    } else if (status == 2){
      color = Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
      onPressed: () {
          appState.updateSelected(number);
          print("Status: $status");
    }, child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text("${number + 1}")));
  }
}

// Placeholder action for unimplemented buttons.
void placeholderAction() {
  print("Placeholder Action Executed");
}