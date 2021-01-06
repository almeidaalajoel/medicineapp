import 'package:flutter/material.dart';
import 'data.dart';

class TakeMedicine extends StatefulWidget {
  @override
  _TakeMedicineState createState() => _TakeMedicineState();
}

class _TakeMedicineState extends State<TakeMedicine> {
  List<MedInfo> _meds = List();
  Map<String, int> _medSet = Map();
  bool adding = false;
  bool deleting = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  int index;

  @override
  void initState() {
    _databaseHelper.initializeDatabase().then((value) {
      _databaseHelper.getMeds().then((_med) {
        setState(() {
          _meds = _med;
          for (int i = 0; i < _meds.length; i++) {
            if (_meds[i].display == 0) {
              _medSet[_meds[i].name] = _meds[i].id;
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
          deleting = false;
        });
        return;
      },
      child: Stack(
        children: [
          Container(
            alignment: Alignment(0, .5),
            child: Container(
              height: 550,
              width: 400,
              child: ListView.builder(
                itemBuilder: (context, i) {
                  return ElevatedButton(
                    child: Text('${_medSet.keys.elementAt(i)}'),
                    onLongPress: () {
                      setState(() {
                        adding = false;
                        deleting = true;
                        index = i;
                      });
                    },
                    onPressed: () async {
                      var medInfo = MedInfo(
                        medDateTime: DateTime.now(),
                        name: _medSet.keys.elementAt(i),
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
                        _databaseHelper.insertMed(medInfo).then((newId) {
                          setState(() {
                            adding = !adding;
                            _medSet[string] = newId;
                          });
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
          deleting
              ? Align(
                  alignment: Alignment(0, -.8),
                  child: buttonRow(index),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buttonRow(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.red),
            child: Text(
              _medSet.keys.elementAt(i).length > 11
                  ? 'Delete History ${_medSet.keys.elementAt(i).substring(0, 11)}...'
                  : 'Delete History ${_medSet.keys.elementAt(i)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              setState(() {
                _databaseHelper.deleteName(_medSet.keys.elementAt(i));
                _medSet.remove(_medSet.keys.elementAt(i));
                deleting = false;
              });
            },
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.yellow),
            child: Text(
              _medSet.keys.elementAt(i).length > 11
                  ? 'Delete Button ${_medSet.keys.elementAt(i).substring(0, 11)}...'
                  : 'Delete Button ${_medSet.keys.elementAt(i)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              setState(() {
                _databaseHelper.delete(_medSet[_medSet.keys.elementAt(i)]);
                _medSet.remove(_medSet.keys.elementAt(i));
                deleting = false;
              });
            },
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.grey[200]),
            child: Text(
              'Cancel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              setState(() {
                deleting = false;
              });
            },
          ),
        ),
      ],
    );
  }
}
