import 'package:flutter/material.dart';
import 'data.dart';

class TakeMedicine extends StatefulWidget {
  @override
  _TakeMedicineState createState() => _TakeMedicineState();
}

class _TakeMedicineState extends State<TakeMedicine> {
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    _databaseHelper.initializeDatabase().then((value) {
      print('-----database initialized');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          var medInfo = MedInfo(
            medDateTime: DateTime.now(),
            name: 'Iron',
            note: 'note',
          );
          _databaseHelper.insertMed(medInfo);
        },
        child: Text('test'),
      ),
    );
  }
}
