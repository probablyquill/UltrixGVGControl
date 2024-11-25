import "package:flutter/material.dart";
import "gvg.dart";

const inputs = 144;
const outputs = 144;

void main() {
  runApp( MyApp() );
}

void test(int number) {
  print(number);
}

class IOButton extends StatelessWidget {
  final String label;
  final int id;

  const IOButton({super.key, required this.label, required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: () => test(id), child: Text(label))
      );
  }
}
Widget createButtons() {
  List<Widget> list = <IOButton>[];
  
  for (int i = 1; i <= inputs; i++) {
    list.add(IOButton(
      id: i,
      label: i.toString(),
      )
    );
  }

  return GridView.count(
    crossAxisSpacing: 1,
    mainAxisSpacing: 1, 
    crossAxisCount: 24,
    childAspectRatio: 4/2,
    children: list,
    );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("I don't know what I'm doing.")
          ),
        body: createButtons()
        )
      );
  }
}