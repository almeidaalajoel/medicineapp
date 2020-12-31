import 'package:flutter/material.dart';
import 'data.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<MedInfo> _meds = List();
  Set<String> _stringSet = Set();
  Set<MedInfo> _medSet = Set();
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    _databaseHelper.initializeDatabase().then((value) {
      _databaseHelper.getMeds().then((_med) {
        setState(() {
          _meds = _med;
          for (int i = _meds.length - 1; i >= 0; i--) {
            if (_stringSet.contains(_meds[i].name)) {
              continue;
            } else {
              _stringSet.add(_meds[i].name);
              _medSet.add(_meds[i]);
            }
          }
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _medSet == null
        ? Container()
        : ListView.builder(
            itemBuilder: (context, i) {
              var medTime = DateFormat('yyyy MMMM d hh:mm aa')
                  .format(_medSet.elementAt(i).medDateTime);
              return Container(
                child: Text(
                    '$medTime, ${_medSet.elementAt(i).note}, ${_medSet.elementAt(i).name}'),
              );
            },
            itemCount: _medSet.length,
          );
  }
}
