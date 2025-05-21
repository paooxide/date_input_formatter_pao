import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_input_formatter_pao/date_input_formatter_pao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateInputFormatter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Optional: for Material 3 styling
      ),
      home: const MyHomePage(title: 'DateInputFormatter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _dateController1 = TextEditingController();
  final TextEditingController _dateController2 = TextEditingController();
  final TextEditingController _dateController3 = TextEditingController();

  @override
  void dispose() {
    _dateController1.dispose();
    _dateController2.dispose();
    _dateController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Enter date (dd/MM/yyyy):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController1,
              decoration: const InputDecoration(
                hintText: 'DD/MM/YYYY',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(pattern: 'dd/MM/yyyy'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter date (MM-dd-yy) with placeholder \'_\':',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController2,
              decoration: const InputDecoration(
                hintText: 'MM-DD-YY',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(pattern: 'MM-dd-yy', placeholderChar: '_'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter date (yyyy.MM.dd):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController3,
              decoration: const InputDecoration(
                hintText: 'YYYY.MM.DD',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(pattern: 'yyyy.MM.dd'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
