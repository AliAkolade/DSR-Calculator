import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:splash_view/source/presentation/pages/pages.dart';
import 'package:splash_view/source/presentation/widgets/done.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'OKB Homes: DSR Calculator',
        debugShowCheckedModeBanner: false,
        home: SplashView(
            backgroundColor: const Color.fromRGBO(37, 33, 34, 1),
            logo: Image.asset('assets/dsrLogo.png'),
            loadingIndicator: Column(children: const [
              CircularProgressIndicator(color: Color.fromRGBO(246, 207, 96, 1)),
              SizedBox(height: 20)
            ]),
            bottomLoading: true,
            done: Done(const MyHomePage(title: 'DSR Calculator'))));
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
        appBar: AppBar(
            title:
                Text(widget.title, style: const TextStyle(color: Colors.black)),
            backgroundColor: const Color.fromRGBO(246, 207, 96, 1)),
        body: const SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: DSRForm())));
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
  TextEditingController yearOfBirth = TextEditingController(text: "2000");
  TextEditingController yearOfEmployment = TextEditingController(text: "2023");
  TextEditingController netSalary = TextEditingController(text: "0");
  TextEditingController mortgageAmount =
      TextEditingController(text: "15000000");
  TextEditingController mortgageInterest = TextEditingController(text: "10");
  TextEditingController mortgageTenure = TextEditingController(text: "1");
  TextEditingController maxAge = TextEditingController(text: "60");
  TextEditingController maxService = TextEditingController(text: "35");
  TextEditingController dsrLimit = TextEditingController(text: "30");

  static const List<String> intNames = [
    "Monthly",
    "Quarterly",
    "Bi-Annually",
    "Annually"
  ];
  static const List<int> intPeriods = [12, 4, 2, 1];

  int mPeriod = 0;
  double emi = 0.0;
  double dsr = 0.0;
  int age = 0;
  int lenService = 0;
  int retireAge = 0;
  int retireService = 0;
  int noPayments = 12;
  String interval = "Monthly";
  final NumberFormat usCurrency = NumberFormat('#,###.##', 'en_US');

  editConstants() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: const Text('Constants'), children: <
              Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(children: [
                  TextFormField(
                      controller: maxAge,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: 'Retirement Age (Yrs)'),
                      onChanged: (value) {
                        retireAge = int.parse(value) -
                            (DateTime.now().year - int.parse(yearOfBirth.text));
                        getMaxPeriod();
                      }),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: maxService,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: 'Retirement Length of Service (Yrs)'),
                      onChanged: (value) {
                        retireService = int.parse(value) -
                            (DateTime.now().year -
                                int.parse(yearOfEmployment.text));
                        getMaxPeriod();
                      }),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: dsrLimit,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration:
                          const InputDecoration(labelText: 'DSR Limit (%)'),
                      onChanged: (value) {
                        calculateDSR();
                      })
                ])),
            SimpleDialogOption(
                onPressed: () {
                  getMaxPeriod();
                  Navigator.pop(context);
                },
                child: const Text('Close'))
          ]);
        });
  }

  calculateEMI() {
    num temp = pow(
        (1 + ((int.parse(mortgageInterest.text) / 100) / noPayments)),
        (mPeriod * noPayments));
    setState(() {
      emi = double.parse(
              mortgageAmount.text.replaceAll("₦ ", "").replaceAll(",", "")) *
          ((((int.parse(mortgageInterest.text) / 100) / noPayments) * temp) /
              (temp - 1));
    });
    calculateDSR();
  }

  getMaxPeriod() {
    setState(() {
      mPeriod = max(retireAge, retireService);
      mortgageTenure.text = mPeriod.toString();
    });
    calculateEMI();
  }

  calculateDSR() {
    setState(() {
      dsr = double.parse(((emi /
                  (double.parse(netSalary.text
                          .replaceAll("₦ ", "")
                          .replaceAll(",", "")) *
                      (12 / noPayments))) *
              100)
          .toStringAsFixed(3));
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      age = DateTime.now().year - int.parse(yearOfBirth.text);
      retireAge = int.parse(maxAge.text) -
          (DateTime.now().year - int.parse(yearOfBirth.text));
      lenService = DateTime.now().year - int.parse(yearOfEmployment.text);
      retireService = int.parse(maxService.text) -
          (DateTime.now().year - int.parse(yearOfEmployment.text));
      getMaxPeriod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          TextFormField(
              controller: yearOfBirth,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  icon: Icon(Icons.person), labelText: 'Birth Year'),
              onChanged: (value) {
                setState(() {
                  age = DateTime.now().year - int.parse(value);
                  retireAge = int.parse(maxAge.text) -
                      (DateTime.now().year - int.parse(value));
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
                  retireService = int.parse(maxService.text) -
                      (DateTime.now().year - int.parse(value));
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
              inputFormatters: [
                CurrencyInputFormatter(
                    leadingSymbol: "₦",
                    useSymbolPadding: true,
                    mantissaLength: 1)
              ],
              decoration: const InputDecoration(
                  icon: Icon(Icons.person), labelText: 'Net Salary (Monthly)'),
              onChanged: (text) {
                calculateDSR();
              }),
          const SizedBox(height: 20),
          Row(children: [
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: mortgageAmount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyInputFormatter(
                          leadingSymbol: "₦",
                          useSymbolPadding: true,
                          mantissaLength: 1)
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Mortgage Amount'),
                    onChanged: (value) {
                      calculateEMI();
                    })),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: mortgageInterest,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Interest (%)'),
                    onChanged: (value) {
                      calculateEMI();
                    })),
            const SizedBox(width: 10),
            Expanded(
                child: TextFormField(
                    controller: mortgageTenure,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Tenure (Yrs)'),
                    onChanged: (value) {
                      setState(() {
                        mPeriod = int.parse(value);
                      });
                      calculateEMI();
                    }))
          ]),
          const SizedBox(height: 5),
          Row(children: [
            const SizedBox(width: 10),
            DropdownButton(
                value: interval,
                items: intNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    interval = value!;
                    noPayments = intPeriods.elementAt(intNames.indexOf(value));
                  });
                  calculateEMI();
                }),
            const SizedBox(width: 30),
            Text("Installments = ₦${usCurrency.format(emi)}")
          ]),
          const SizedBox(height: 30),
          Text("DSR - $dsr%"),
          const SizedBox(height: 5),
          (dsr <= int.parse(dsrLimit.text))
              ? const Text("Qualified",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold))
              : const Text("Not Qualified",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          OutlinedButton(
              onPressed: () {
                editConstants();
              },
              child: const Text("Edit Constants",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold)))
        ]));
  }
}
