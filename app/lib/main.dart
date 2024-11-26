import "package:flutter/material.dart";
import "gvg.dart";

const inputs = 144;
const outputs = 144;

int selectedDestination = 1;
int selectedSource = 1;

void main() {
  runApp(const MyApp());
}

void test(int number) {
  print(number);
}

void updateSelected(bool input, int number) {
  if (input) {
    selectedSource = number;
  } else {
    selectedDestination = number;
  }
}

/* Widgets to create for the application:
1.) Segment for the Input Selection Buttons
2.) Segment for the Output Selection Buttons
3.) Widget with the Take button and selected I/O lables.
*/

class IOButton extends StatelessWidget {
  final String label;
  final int id;

  // True = Input, False = Output
  final bool input;

  const IOButton(
      {super.key, required this.label, required this.id, required this.input});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: () => updateSelected(input, id),
            child: Text(label)));
  }
}

// Generates the correct number of buttons with the assigned data needed to update 
List<Widget> buildGrid(bool inputType) {
  List<Widget> list = <IOButton>[];

  for (int i = 1; i <= inputs; i++) {
    list.add(IOButton(
      id: i,
      label: i.toString(),
      input: inputType,
    ));
  }

  return list;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.green,
                title: const Text("I don't know what I'm doing.")),
            body: const Text("Text on the screen.")));
  }
}
