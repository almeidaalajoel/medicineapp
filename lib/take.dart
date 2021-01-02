import 'package:flutter/material.dart';
import 'data.dart';

class TakeMedicine extends StatefulWidget {
  @override
  _TakeMedicineState createState() => _TakeMedicineState();
}

class _TakeMedicineState extends State<TakeMedicine> {
  List<MedInfo> _meds = List();
  Set<String> _stringSet = Set();
  List<MedInfo> _medSet = List();
  bool adding = false;
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
              _medSet.insert(0, _meds[i]);
            }
          }
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          adding = false;
        });
        return;
      },
      child: Stack(
        children: [
          Container(
            //color: Colors.red,
            alignment: Alignment(0, 1),
            child: Container(
              //color: Colors.green,
              height: 550,
              width: 400,
              child: ListView.builder(
                itemBuilder: (context, i) {
                  return ElevatedButton(
                    child: Text('${_medSet[i].name}'),
                    onPressed: () async {
                      var medInfo = MedInfo(
                        medDateTime: DateTime.now(),
                        name: _medSet[i].name,
                        note: 'note',
                        display: 1,
                      );
                      _databaseHelper.insertMed(medInfo);
                    },
                  );
                },
                itemCount: _medSet.length,
              ),
            ),
          ),
          adding
              ? Container(
                  alignment: Alignment(-.3, .95),
                  child: Container(
                    alignment: Alignment(0, 1),
                    width: 200,
                    height: 100,
                    child: TextField(
                      autofocus: true,
                      onSubmitted: (string) {
                        var medInfo = MedInfo(
                          medDateTime: DateTime.now(),
                          name: string,
                          note: 'note',
                          display: 0,
                        );
                        _databaseHelper.insertMed(medInfo);
                        setState(() {
                          if (!_stringSet.contains(medInfo.name)) {
                            _medSet.insert(_medSet.length, medInfo);
                          }
                          _stringSet.add(medInfo.name);
                          adding = !adding;
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'New Medicine',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Container(
            alignment: Alignment(.95, .95),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  adding = !adding;
                });
              },
            ),
          ),
          Container(
            alignment: Alignment(0, -.9),
            child: Text(
              'Medicine',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
