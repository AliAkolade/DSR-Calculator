import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'DSR Calculator',
        debugShowCheckedModeBanner: false,
        home: MyHomePage(title: 'DSR Calculator'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[DSRForm()]));
  }
}

class DSRForm extends StatefulWidget {
  const DSRForm({super.key});

  @override
  DSRFormState createState() {
    return DSRFormState();
  }
}

class DSRFormState extends State<DSRForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController yearOfBirth = TextEditingController();
  TextEditingController yearOfEmployment = TextEditingController();
  TextEditingController netSalary = TextEditingController();

  static const int maxAge = 60;
  static const int maxService = 35;
  static const int dsr = 30;
  static const int mortgageAmount = 35;
  static const int mortgageInterest = 35;
  static const int mortgagePeriod = 35;
  static const double emi = 35;

  calculateDSR() {}

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
              controller: yearOfBirth,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  icon: Icon(Icons.person), labelText: 'Birth Year')),
          // Row(children: [
          //   Text("Years till retirement - ${DateTime.now().year-int.parse(yearOfBirth.text)}")
          // ]),
          TextFormField(
              controller: yearOfEmployment,
              decoration: const InputDecoration(
                  icon: Icon(Icons.person), labelText: 'Employment Year')),
          TextFormField(
              controller: netSalary,
              decoration: const InputDecoration(
                  icon: Icon(Icons.person), labelText: 'Net Salary'))
        ]));
  }
}
