import 'package:flutter/material.dart';
import 'data.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<MedInfo> _meds;
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    _databaseHelper.initializeDatabase().then((value) {
      _databaseHelper.getMeds().then((_med) {
        setState(() {
          _meds = _med;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _meds == null
        ? Container()
        : GridView.count(
            crossAxisCount: 2,
            children: List.generate(_meds.length, (i) {
              var medTime = DateFormat('yyyy MMMM d hh:mm aa')
                  .format(_meds[_meds.length - (i + 1)].medDateTime);
              return Container(
                child: Text(
                  '$medTime, ${_meds[_meds.length - (i + 1)].note}, ${_meds[_meds.length - (i + 1)].name}',
                ),
              );
            }),
          );
  }
}
