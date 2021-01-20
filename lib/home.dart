import 'package:flutter/material.dart';
import 'data.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'dart:core';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<MedInfo> _meds = List();
  Set<String> _stringSet = Set();
  Set<MedInfo> _medSetToday = Set();
  Set<MedInfo> _medSetYesterday = Set();
  Set<MedInfo> _medSetOld = Set();
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
              if (_meds[i].display == 1) {
                _stringSet.add(_meds[i].name);
                if (DateTime.now().day == _meds[i].medDateTime.day &&
                    DateTime.now().month == _meds[i].medDateTime.month &&
                    DateTime.now().year == _meds[i].medDateTime.year) {
                  _medSetToday.add(_meds[i]);
                } else if (DateTime.now().subtract(Duration(days: 1)).day ==
                        _meds[i].medDateTime.day &&
                    DateTime.now().subtract(Duration(days: 1)).month ==
                        _meds[i].medDateTime.month &&
                    DateTime.now().subtract(Duration(days: 1)).year ==
                        _meds[i].medDateTime.year) {
                  _medSetYesterday.add(_meds[i]);
                } else {
                  _medSetOld.add(_meds[i]);
                }
              }
            }
          }
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (_medSetToday == null &&
            _medSetYesterday == null &&
            _medSetOld == null)
        ? Container(
            child: Text(''),
          )
        : WillPopScope(
            onWillPop: () {
              return;
            },
            child: Container(
              // color: Color.fromARGB(180, 30, 44, 52),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 25),
                    child: Text(
                      'Most Recent Medications',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(3),
                      itemBuilder: (context, i) {
                        Set<MedInfo> medSet;
                        if (i == 0 ||
                            i == _medSetToday.length + 1 ||
                            i ==
                                _medSetToday.length +
                                    _medSetYesterday.length +
                                    2) {
                          return _textReturn(
                              i, _medSetToday, _medSetYesterday, _medSetOld);
                        }
                        medSet = _findMedSet(i);
                        i = _fixI(i, _medSetToday, _medSetYesterday);
                        var medTime = DateFormat('MMMM d h:mm aa')
                            .format(medSet.elementAt(i).medDateTime);
                        Duration duration = DateTime.now()
                            .difference(medSet.elementAt(i).medDateTime);
                        String hours =
                            duration.inHours == 1 || duration.inHours == 0
                                ? 'hour'
                                : 'hours';
                        String d = duration.inHours == 0
                            ? 'less than an'
                            : '${duration.inHours}';
                        return Container(
                          height: 100,
                          //width: 50,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                medSet.elementAt(i).name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' Last taken $d $hours ago',
                                style: TextStyle(
                                  fontSize: 18,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('On $medTime '),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: _findColor(duration.inHours),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        );
                      },
                      itemCount: _medSetToday.length +
                          _medSetYesterday.length +
                          _medSetOld.length +
                          3,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _textReturn(int i, Set<MedInfo> _medSetToday,
      Set<MedInfo> _medSetYesterday, Set<MedInfo> _medSetOld) {
    String text;
    if (i == 0) {
      text = "Today: ${DateFormat('MMMM d').format(DateTime.now())}";
      if (_medSetToday.length == 0) {
        return Text('');
      }
    } else if (i == _medSetToday.length + 1) {
      text =
          'Yesterday: ${DateFormat('MMMM d').format(DateTime.now().subtract(Duration(days: 1)))}';
      if (_medSetYesterday.length == 0) {
        return Text('');
      }
    } else if (i == _medSetToday.length + _medSetYesterday.length + 2) {
      text = 'Old:';
      if (_medSetOld.length == 0) {
        return Text('');
      }
    }
    return Column(
      children: [
        (i == _medSetToday.length + 1 && _medSetToday.length != 0) ||
                (i == _medSetToday.length + _medSetYesterday.length + 2 &&
                    (_medSetToday.length != 0 || _medSetYesterday.length != 0))
            ? Divider(
                thickness: 2,
                color: Colors.black,
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  int _fixI(int i, Set<MedInfo> _medSetToday, Set<MedInfo> _medSetYesterday) {
    if (i < _medSetToday.length + 1) {
      i -= 1;
    }
    if (i > _medSetToday.length + 1 &&
        i < _medSetToday.length + _medSetYesterday.length + 2) {
      i -= _medSetToday.length + 2;
    }
    if (i > _medSetToday.length + _medSetYesterday.length + 2) {
      i -= _medSetToday.length + _medSetYesterday.length + 3;
    }
    return i;
  }

  Set<MedInfo> _findMedSet(int i) {
    if (i < _medSetToday.length + 1) {
      return _medSetToday;
    } else if (i < _medSetToday.length + _medSetYesterday.length + 2) {
      return _medSetYesterday;
    } else {
      return _medSetOld;
    }
  }

  Color _findColor(int duration) {
    if (duration < 12) {
      return Colors.green;
    } else if (12 <= duration && duration < 36) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
