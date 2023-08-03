import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hello/services/crud/vitals_CRUD.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:hello/constants/routes.dart';

import 'package:hello/services/auth/auth_service.dart';

import 'package:workmanager/workmanager.dart';
import '../Utilities/show_error_dialog.dart';
import '../enum/menu_action.dart';
import 'package:http/http.dart' as http;

import '../enum/menu_items.dart';
import '../services/auth/block/auth_bloc.dart';
import '../services/auth/block/auth_event.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  Connectivity connectivity = Connectivity();
  late final SQLHelper _sqlHelper;
  List<Map<String, dynamic>> _journals = [];
  String get userEmail => Authservice.firebase().currentUser!.email!;

  void refreshJournals() async {
    final data = await _sqlHelper.getItems();
    setState(() {
      _journals = data;
      _foundUsers = _journals;
    });
  }

  _NotesViewState() {
    _selectedVal = tempUnit[0];
  }

  List<String> tempUnit = ["Celcius", "Farenheit"];
  String _selectedVal = "";
  List userData = [];
  // Future<void> getdata() async {
  //   String uri = "http://10.0.2.2/project/view_data.php";
  //   try {
  //     var response = await http.get(Uri.parse(uri));
  //     setState(() {
  //       userData = jsonDecode(response.body);
  //     });
  //   } catch (e) {
  //     print("$e");
  //   }
  // }

  String dropdownValue = 'Male';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sqlHelper = SQLHelper();
    // getdata();

    refreshJournals();
  }

  TextEditingController _idController = TextEditingController();
  TextEditingController _tempuratureController = TextEditingController();
  TextEditingController _resprateController = TextEditingController();
  TextEditingController _bldpresController = TextEditingController();
  TextEditingController _puloxController = TextEditingController();
  TextEditingController _testdateController = TextEditingController();
  TextEditingController _entrydateController = TextEditingController();
  TextEditingController _sernoController = TextEditingController();

  Future<void> _updateItem(
      {required int id,
      required String tempurature,
      required String resprate,
      required String bldpres,
      required String pulox,
      required String testdate,
      required String entrydate,
      required String serno,
      required uploaded}) async {
    await _sqlHelper.updateItem(
        id: id,
        tempurature: tempurature,
        resprate: resprate,
        bldpres: bldpres,
        pulox: pulox,
        testdate: testdate,
        entrydate: entrydate,
        serno: serno,
        uploaded: uploaded);
    refreshJournals();
  }

  Future<void> _delete({required int id}) async {
    await _sqlHelper.deleteItem(id: id);
    refreshJournals();
  }

  Future<void> insertRecord(String tempurature, resprate, bldpres) async {
    try {
      String uri = "http://10.0.2.2/project/insert_record.php";
      await http.post(Uri.parse(uri), body: {
        "tempurature": tempurature,
        "resprate": resprate,
        "bldpres": bldpres,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> scanBarcode() async {
    String barcodeScanres;
    try {
      barcodeScanres = await FlutterBarcodeScanner.scanBarcode(
          '#FFFFFF', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanres = 'Failed to get Platform version';
    }
    setState(() {
      _idController.text = barcodeScanres;
    });
  }

  Future<void> _addItem() async {
    String temp = _tempuratureController.text + " " + _selectedVal;

    await _sqlHelper.createUser(
        id: int.parse(_idController.text),
        tempurature: temp,
        resprate: _resprateController.text,
        bldpres: _bldpresController.text,
        pulox: _puloxController.text,
        testdate: _testdateController.text,
        entrydate: _entrydateController.text,
        serno: _sernoController.text,
        uploaded: 'false');
    refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _idController.text = existingJournal['id'].toString();

      _resprateController.text = existingJournal['resprate'];
      _bldpresController.text = existingJournal['bldpres'];
      _puloxController.text = existingJournal['pulox'];
      _testdateController.text = existingJournal['testdate'];
      _entrydateController.text = existingJournal['entrydate'];
      _sernoController.text = existingJournal['serno'];
      int index = existingJournal['tempurature'].indexOf('Celcius');
      if (index == -1) {
        index = existingJournal['tempurature'].indexOf('Farenheit');
      }
      _tempuratureController.text =
          existingJournal['tempurature'].substring(0, index - 1);

      var res = existingJournal['tempurature'].substring(index);
      _selectedVal = res;
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                            onPressed: scanBarcode,
                            icon: const Icon(Icons.qr_code)),
                        hintText: "Enter patient ID or Scan",
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Row(children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextField(
                            controller: _tempuratureController,
                            //keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'tempurature',
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Flexible(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                              child: DropdownButtonFormField(
                                value: _selectedVal,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: tempUnit.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVal = value as String;
                                  });
                                },
                              )))
                    ]),
                    TextField(
                      controller: _resprateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'resprate Pressure',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _bldpresController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'blood Pressure',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _puloxController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Pulse Rate',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _testdateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today_rounded),
                        hintText: "Select test Date",
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _testdateController.text =
                                DateFormat("dd-MM-yyyy").format(pickedDate);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _entrydateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today_rounded),
                        hintText: "Select Entry Date",
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _entrydateController.text =
                                DateFormat("dd-MM-yyyy").format(pickedDate);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _sernoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'serno',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            try {
                              await _addItem();
                            } on UserAlreadyExists {
                              await showErrorDialog(
                                  context, 'Patient Already Exists');
                            }
                          }

                          if (id != null) {
                            await _updateItem(
                                id: id,
                                tempurature: _tempuratureController.text +
                                    " " +
                                    _selectedVal,
                                resprate: _resprateController.text,
                                bldpres: _bldpresController.text,
                                pulox: _puloxController.text,
                                testdate: _testdateController.text,
                                entrydate: _entrydateController.text,
                                serno: _sernoController.text,
                                uploaded: 'false');
                          }
                          _idController.text = '';
                          _tempuratureController.text = '';
                          _bldpresController.text = '';
                          _resprateController.text = '';
                          _entrydateController.text = '';
                          _puloxController.text = '';
                          _sernoController.text = '';
                          _testdateController.text = '';
                          _entrydateController.text = '';

                          Navigator.of(context).pop(true);
                        },
                        child: const Text('save')),
                  ],
                ),
              ),
            ));
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) =>
      PopupMenuItem<MenuItem>(value: item, child: Text(item.text));
  void onSelected(BuildContext context, MenuItem item) async {
    if (item.text == 'Complaint') {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(newComplaintRoute, (_) => false);
    } else if (item.text == 'logout') {
      final shouldLogout = await showLogOutDialog(context);
      if (shouldLogout) {
        context.read<AuthBloc>().add(const AuthEventLogOut());
      }
    }
  }

  List<Map<String, dynamic>> _foundUsers = [];
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _journals;
    } else {
      results = _journals
          .where(
              (user) => user["testdate"].contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals'),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              ...MenuItems.itemsfirst.map(buildItem).toList(),
            ],
          ),
        ],
        backgroundColor: Colors.amberAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                hintText: "Search",
                suffixIcon: const Icon(Icons.search),
                // prefix: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.orange[200],
                        margin: const EdgeInsets.all(15),
                        child: ListTile(
                          onTap: () {
                            return _showForm(_foundUsers[index]['id']);
                          },
                          title: Text(_foundUsers[index]['id'].toString()),
                          trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        await Workmanager().registerOneOffTask(
                                            "UPLOAD", 'first',
                                            constraints: Constraints(
                                                networkType:
                                                    NetworkType.connected),
                                            inputData: {
                                              'id': _journals[index]['id'],
                                              'tempurature': _journals[index]
                                                  ['tempurature'],
                                              'resprate': _journals[index]
                                                  ['resprate'],
                                              'bldpres': _journals[index]
                                                  ['bldpres'],
                                              'pulox': _journals[index]
                                                  ['pulox'],
                                              'testdate': _journals[index]
                                                  ['testdate'],
                                              'entrydate': _journals[index]
                                                  ['entrydate'],
                                              'serno': _journals[index]
                                                  ['serno'],
                                            });
                                        await _updateItem(
                                            id: _journals[index]['id'],
                                            tempurature: _journals[index]
                                                ['tempurature'],
                                            resprate: _journals[index]
                                                ['resprate'],
                                            bldpres: _journals[index]
                                                ['bldpres'],
                                            pulox: _journals[index]['pulox'],
                                            testdate: _journals[index]
                                                ['testdate'],
                                            entrydate: _journals[index]
                                                ['entrydate'],
                                            serno: _journals[index]['serno'],
                                            uploaded: 'true');
                                      },
                                      icon: Icon((_journals[index]
                                                  ['uploaded'] ==
                                              'true')
                                          ? Icons.check
                                          : Icons.upload)),
                                  IconButton(
                                      onPressed: () =>
                                          _delete(id: _journals[index]['id']),
                                      icon: const Icon(Icons.delete)),
                                ],
                              )),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found Please try with diffrent search',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
        // onPressed: () async {
        //   await ApiServices.uploadVitals(context: context);
        // },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text("Are you sure You Want to Log out"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Ok')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'))
        ],
      );
    },
  ).then((value) => value ?? false);
}
//   