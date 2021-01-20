import 'package:flutter/material.dart';
import 'data.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<MedInfo> _meds;
  List<MedInfo> _toRemove = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool deleting = false;
  int currId;

  @override
  void initState() {
    _databaseHelper.initializeDatabase().then((value) {
      _databaseHelper.getMeds().then((_med) {
        setState(() {
          _meds = _med;
          _meds.forEach((med) {
            if (med.display == 0) {
              _toRemove.add(med);
            }
          });
          _meds.removeWhere((med) => _toRemove.contains(med));
          _meds = _meds.reversed.toList();
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _meds == null
        ? Container()
        : WillPopScope(
            onWillPop: () {
              return;
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    children: List.generate(_meds.length, (i) {
                      var medDay =
                          DateFormat('MMMM d').format(_meds[i].medDateTime);
                      var medTime =
                          DateFormat('h:mm aa').format(_meds[i].medDateTime);
                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            currId = i;
                            deleting = true;
                          });
                        },
                        child: Container(
                          //width: 50,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                medDay,
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                _meds[i].name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Taken at $medTime',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(100, 30, 47, 74),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                deleting
                    ? Text('Are you sure you want to delete this entry?')
                    : Text(''),
                deleting
                    ? Text(DateFormat('MMMM d h:mm aa ')
                            .format(_meds[currId].medDateTime) +
                        _meds[currId].name)
                    : Text(''),
                deleting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _databaseHelper.delete(_meds[currId].id);
                                    deleting = false;
                                    _meds.remove(_meds[currId]);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                child: Text(
                                  'Delete',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    deleting = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.grey[200]),
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ])
                    : Container()
              ],
            ),
          );
  }
}
