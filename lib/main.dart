import 'dart:math';

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
            mainAxisAlignment: MainAxisAlignment.start,
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
  TextEditingController yearOfBirth = TextEditingController(text: "1960");
  TextEditingController yearOfEmployment = TextEditingController(text: "1998");
  TextEditingController netSalary = TextEditingController(text: "600000");

  static const int maxAge = 60;
  static const int maxService = 35;
  static const int dsrLimit = 30;
  static const int mAmount = 15000000;
  static const int mInterest = 10;
  int mPeriod = 0;
  double emi = 0.0;
  double dsr = 0.0;
  int age = 0;
  int lenService = 0;
  int retireAge = 0;
  int retireService = 0;

  calculateEMI() {
    num temp = pow((1 + ((mInterest / 100) / 12)), (mPeriod * 12));
    setState(() {
      emi = mAmount * ((((mInterest / 100) / 12) * temp) / (temp - 1));
    });
    calculateDSR();
  }

  getMaxPeriod() {
    setState(() {
      mPeriod = max(retireAge, retireService);
    });
    calculateEMI();
  }

  calculateDSR() {
    setState(() {
      dsr = double.parse(
          ((emi / double.parse(netSalary.text)) * 100).toStringAsFixed(3));
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      age = DateTime.now().year - int.parse(yearOfBirth.text);
      retireAge = maxAge - (DateTime.now().year - int.parse(yearOfBirth.text));
      lenService = DateTime.now().year - int.parse(yearOfEmployment.text);
      retireService =
          maxService - (DateTime.now().year - int.parse(yearOfEmployment.text));
      getMaxPeriod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  controller: yearOfBirth,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person), labelText: 'Birth Year'),
                  onChanged: (value) {
                    setState(() {
                      age = DateTime.now().year - int.parse(value);
                      retireAge =
                          maxAge - (DateTime.now().year - int.parse(value));
                      getMaxPeriod();
                    });
                  }),
              Row(children: [
                const SizedBox(width: 40),
                Text("Age = $age"),
                const Spacer(),
                Text("Retires in $retireAge years"),
                const SizedBox(width: 5)
              ]),
              const SizedBox(height: 15),
              TextFormField(
                  keyboardType: TextInputType.number,
                  controller: yearOfEmployment,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person), labelText: 'Employment Year'),
                  onChanged: (value) {
                    setState(() {
                      lenService = DateTime.now().year - int.parse(value);
                      retireService =
                          maxService - (DateTime.now().year - int.parse(value));
                      getMaxPeriod();
                    });
                  }),
              Row(children: [
                const SizedBox(width: 40),
                Text("Length of Service = $lenService"),
                const Spacer(),
                Text("Retires in $retireService years"),
                const SizedBox(width: 5)
              ]),
              const SizedBox(height: 15),
              TextFormField(
                  keyboardType: TextInputType.number,
                  controller: netSalary,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Net Salary (Monthly)'),
                  onChanged: (text) {
                    calculateDSR();
                  }),
              const SizedBox(height: 20),
              Text("DSR - $dsr%"),
              const SizedBox(height: 5),
              (dsr <= dsrLimit)
                  ? const Text("Qualified")
                  : const Text("Not Qualified"),
              const SizedBox(height: 20),
            ]));
  }
}
