import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gvg.dart';

void main() {
  runApp(MyApp());
}

// ChangeNotifier will manage all recieved router info.
// A bit unsure if this should be strucutred as so, it might be more correct to 
// break some or all of it into a stateful SwitcherPanel widget.

class AppState extends ChangeNotifier {
  // true = Source Select, false = Dest Select
  String panelIP = "192.168.77.225";
  int panelPort = 12345;
  bool panelMode = true;

  int activeSource = -1;
  int selectedSource = -1;
  int selectedButton = -1;
  int activeDest = -1;

  // Will need to be set by the response from the router.
  List<String> sourceNames = <String>[];
  List<String> destNames = <String>[];
  String activeSrcName = "";
  String activeDestName = "";

  var buttonList = <int>[];

  void generateButtons() {
    if (buttonList.isEmpty) {
      for (int i = 0; i < 144; i++) {
          buttonList.add(i);
      }
    }
  }

  void updateSelected(int button) async {
    selectedButton = button;

    if (panelMode) {
      selectedSource = button;
    } else {
      activeDest = button;
    }
    print("Selected $button");
    print("Panel Mode: ${(panelMode) ? "Source" : "Dest"}");
    print("Active Source: $activeSource");
    print("Active Dest: $activeDest");
    print("Selected source: $selectedSource");

    // No reason to continue the check if panel is set to sources.
    if (!panelMode) {
      String command = queryDestinationStatus(activeDest);
      List<String> data = await sendCommand(panelIP, panelPort, command);
      if (data.isEmpty) return; //Temporary error handling for lack of connection / bad requests.
      activeSource = gvgDeconvertNumber(data[2]);
      selectedSource = activeSource;
    }

    //not sure why sources only are off by one. need to fix.
    if (sourceNames.length > (selectedSource + 1) && destNames.length > activeDest) {
      activeSrcName = sourceNames[selectedSource + 1];
      activeDestName = destNames[activeDest];
    }

    notifyListeners();
  }

  void setPanelType(bool type) {
    panelMode = type;
    selectedButton = (type) ? selectedSource : activeDest;
    notifyListeners();
  }

  //This only needs to be run occasionally, need to figure out how to do that. Timer?
  void getSrcDestNames() async {
    String command1 = queryDestination();
    String command2 = querySource();

    sourceNames = await sendCommand(panelIP, panelPort, command2);
    destNames = await sendCommand(panelIP, panelPort, command1);
  }

  void executeTake() {
    // Quick check for invalid inputs before firing the command. 
    if (selectedSource < 1 || activeDest < 1) return;
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
    // This should be done differently; both of these only need to be run once on start not every build.
    // However I'm not sure where to put them because they rely on context.
    appState.generateButtons();
    appState.getSrcDestNames();
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
                                  Text(appState.activeDestName),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Source:"),
                                  SizedBox(width: 10),
                                  Text(appState.activeSrcName),
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
        for (var i = 1; i <= appState.buttonList.length; i++)
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
    if (appState.selectedButton == number) {
      // If the panel is in dest mode, selected and activeDest should always be the same.
      if (appState.panelMode) {
        status = (active == number) ? 2 : 1;
      } else {
        status = 2;
      }
    }

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
    }, child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text("$number")));
  }
}

// Placeholder action for unimplemented buttons.
void placeholderAction() {
  print("Placeholder Action Executed");
}