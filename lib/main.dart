import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart'; // Import your Firebase options file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase String List',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  late DatabaseReference _databaseRef;
  List<String> _stringList = [];

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.reference().child('strings');
    _loadStrings();
  }

  void _loadStrings() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<String> stringValues = data.values.cast<String>().toList();
        setState(() {
          _stringList = stringValues;
        });
      } else {
        setState(() {
          _stringList = []; // Initialize with an empty list
        });
      }
    });
  }

  void _addString(String newString) {
    _databaseRef.push().set(newString);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase String List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter a string'),
            ),
          ),
          ElevatedButton(
            onPressed: () => _addString(_textController.text),
            child: Text('Add String'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _stringList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_stringList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
