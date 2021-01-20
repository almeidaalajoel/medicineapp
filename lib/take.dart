import 'package:flutter/material.dart';
import 'data.dart';

class TakeMedicine extends StatefulWidget {
  @override
  _TakeMedicineState createState() => _TakeMedicineState();
}

class _TakeMedicineState extends State<TakeMedicine> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<MedInfo> _meds = List();
  Map<String, int> _medMap = Map();
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
              _medMap[_meds[i].name] = _meds[i].id;
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text(
              'Medicine',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(45.0, 0, 45, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.teal,
                      onPrimary: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                    ),
                    child: Text('${_medMap.keys.elementAt(i)}'),
                    onLongPress: () {
                      setState(() {
                        adding = false;
                        deleting = true;
                        index = i;
                      });
                    },
                    onPressed: () async {
                      var medInfo = MedInfo(
                        medDateTime: DateTime.now().subtract(Duration(days: 0)),
                        name: _medMap.keys.elementAt(i),
                        note: 'note',
                        display: 1,
                      );
                      _databaseHelper.insertMed(medInfo);
                    },
                  ),
                );
              },
              itemCount: _medMap.length,
            ),
          ),
          deleting ? buttonRow(index) : Container(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                adding
                    ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 200,
                          child: TextField(
                            autofocus: true,
                            onSubmitted: (string) {
                              var medInfo = MedInfo(
                                medDateTime: DateTime.now(),
                                name: string,
                                note: 'note',
                                display: 0,
                              );
                              if (!_medMap.keys.contains(string)) {
                                _databaseHelper
                                    .insertMed(medInfo)
                                    .then((newId) {
                                  setState(() {
                                    adding = !adding;
                                    _medMap[string] = newId;
                                  });
                                });
                              }
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
                    : Container(color: Colors.red),
                Align(
                  child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        adding = !adding;
                      });
                    },
                  ),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          )
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
              _medMap.keys.elementAt(i).length > 11
                  ? 'Delete History ${_medMap.keys.elementAt(i).substring(0, 11)}...'
                  : 'Delete History ${_medMap.keys.elementAt(i)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              setState(() {
                _databaseHelper.deleteName(_medMap.keys.elementAt(i));
                _medMap.remove(_medMap.keys.elementAt(i));
                deleting = false;
              });
            },
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.yellow),
            child: Text(
              _medMap.keys.elementAt(i).length > 11
                  ? 'Delete Button ${_medMap.keys.elementAt(i).substring(0, 11)}...'
                  : 'Delete Button ${_medMap.keys.elementAt(i)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              setState(() {
                _databaseHelper.delete(_medMap[_medMap.keys.elementAt(i)]);
                _medMap.remove(_medMap.keys.elementAt(i));
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
