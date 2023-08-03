import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hello/views/upload_file.dart';
import 'package:intl/intl.dart';
import 'package:hello/constants/routes.dart';
import 'package:hello/enum/menu_items.dart';

import 'package:hello/services/auth/auth_service.dart';

import 'package:workmanager/workmanager.dart';
import '../enum/menu_action.dart';
import 'package:http/http.dart' as http;

import '../services/auth/block/auth_bloc.dart';
import '../services/auth/block/auth_event.dart';
import '../services/crud/complaint_CRUD.dart';

class ComplaintView extends StatefulWidget {
  const ComplaintView({super.key});

  @override
  State<ComplaintView> createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  String? file_name;
  PlatformFile? picked_file;
  File? file_to_display;
  FilePickerResult? result;
  String? file_path;
  Uint8List? _file;
  File? file;
  Uint8List? imageInUnit8List;
  void pickfile() async {
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          file_name = result!.files.first.name;
          picked_file = result!.files.first;
          file_path = picked_file!.path.toString();
          file_to_display = File(picked_file!.path.toString());
          _file = file_to_display!.readAsBytesSync();

          _reportlinkController.text = file_path!;
        });
      }
    } catch (e) {
      log("error $e");
      rethrow;
    }
  }

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

  _ComplaintViewState() {
    _selectedVal = durationUnit[0];
    _selectedVal1 = durationUnit[0];
    _selectedVal2 = durationUnit[0];
  }
  List<String> durationUnit = ["Days", "Months"];
  String _selectedVal = "";
  String _selectedVal1 = "";
  String _selectedVal2 = "";

  List userData = [];
  Future<void> getdata() async {
    String uri = "http://10.0.2.2/project/view_data.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        userData = jsonDecode(response.body);
      });
    } catch (e) {
      print("$e");
    }
  }

  String dropdownValue = 'Male';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sqlHelper = SQLHelper();
    getdata();
    refreshJournals();
  }

  TextEditingController _comp1Controller = TextEditingController();
  TextEditingController _dur1Controller = TextEditingController();
  TextEditingController _hdmy1Controller = TextEditingController();
  TextEditingController _comp2Controller = TextEditingController();
  TextEditingController _dur2Controller = TextEditingController();
  TextEditingController _hdmy2Controller = TextEditingController();
  TextEditingController _comp3Controller = TextEditingController();
  TextEditingController _dur3Controller = TextEditingController();
  TextEditingController _hdmy3Controller = TextEditingController();
  TextEditingController _rhController = TextEditingController();
  TextEditingController _reportlinkController = TextEditingController();
  TextEditingController _testdateController = TextEditingController();
  TextEditingController _entrydateController = TextEditingController();
  TextEditingController _sernoController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  Future<void> _updateItem(
      {required int id,
      required String comp1,
      required String dur1,
      required String hdmy1,
      required String comp2,
      required String dur2,
      required String hdmy2,
      required String comp3,
      required String dur3,
      required String hdmy3,
      required String rh,
      required String reportlink,
      required String testdate,
      required String entrydate,
      required String serno,
      required String uploaded}) async {
    await _sqlHelper.updateItem(
        id: id,
        comp1: comp1,
        dur1: dur1,
        hdmy1: hdmy1,
        comp2: comp2,
        dur2: dur2,
        hdmy2: hdmy2,
        comp3: comp3,
        dur3: dur3,
        rh: rh,
        reportlink: reportlink,
        hdmy3: hdmy3,
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

  Future<void> _addItem() async {
    await _sqlHelper.createUser(
        id: int.parse(_idController.text),
        comp1: _comp1Controller.text,
        dur1: _dur1Controller.text + " " + _selectedVal,
        hdmy1: _hdmy1Controller.text,
        comp2: _comp2Controller.text,
        dur2: _dur2Controller.text + " " + _selectedVal1,
        hdmy2: _hdmy2Controller.text,
        comp3: _comp3Controller.text,
        dur3: _dur3Controller.text + " " + _selectedVal2,
        rh: _rhController.text,
        reportlink: _reportlinkController.text,
        hdmy3: _hdmy3Controller.text,
        testdate: _testdateController.text,
        entrydate: _entrydateController.text,
        serno: _sernoController.text,
        uploaded: 'false');
    refreshJournals();
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

  int returnId(Map<String, dynamic> existingJournal, String dur) {
    int index = existingJournal[dur].indexOf('Days');
    if (index == -1) {
      index = existingJournal[dur].indexOf('Months');
    }
    return index;
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);

      _idController.text = existingJournal['id'].toString();
      _comp1Controller.text = existingJournal['comp1'];

      _dur1Controller.text = existingJournal['dur1']
          .substring(0, returnId(existingJournal, "dur1") - 1);
      var res =
          existingJournal['dur1'].substring(returnId(existingJournal, "dur1"));
      _selectedVal = res;
      _hdmy1Controller.text = existingJournal['hdmy1'];
      _comp2Controller.text = existingJournal['comp2'];
      _dur2Controller.text = existingJournal['dur2']
          .substring(0, returnId(existingJournal, "dur2") - 1);
      res =
          existingJournal['dur2'].substring(returnId(existingJournal, "dur2"));
      _selectedVal1 = res;
      _hdmy2Controller.text = existingJournal['hdmy2'];
      _comp3Controller.text = existingJournal['comp3'];
      _dur3Controller.text = existingJournal['dur3']
          .substring(0, returnId(existingJournal, "dur3") - 1);
      res =
          existingJournal['dur3'].substring(returnId(existingJournal, "dur3"));
      _selectedVal2 = res;
      _hdmy3Controller.text = existingJournal['hdmy3'];
      _rhController.text = existingJournal['rh'];

      _reportlinkController.text = existingJournal['reportlink'];

      // final tempDir = await getTemporaryDirectory();

      // file = await File('${tempDir.path}/image.jpg').create();
      // file!.writeAsBytesSync(imageInUnit8List!);

      _testdateController.text = existingJournal['testdate'];
      _entrydateController.text = existingJournal['entrydate'];
      _sernoController.text = existingJournal['serno'];
    }
    // ignore: use_build_context_synchronously
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
                    TextField(
                      // enableSuggestions: false,
                      // autocorrect: false,
                      // keyboardType: TextInputType.emailAddress,
                      controller: _comp1Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'comp1',
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
                    Row(children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextField(
                            controller: _dur1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'dur1',
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
                                items: durationUnit.map((e) {
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
                    const SizedBox(height: 5),
                    TextField(
                      controller: _hdmy1Controller,
                      //  keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'hdmy1',
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
                      controller: _comp2Controller,
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'comp2',
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
                    Row(children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextField(
                            controller: _dur2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'dur2',
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
                                value: _selectedVal1,
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
                                items: durationUnit.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVal1 = value as String;
                                  });
                                },
                              )))
                    ]),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _hdmy2Controller,
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'hdmy2',
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
                      controller: _comp3Controller,
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'comp3',
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
                    Row(children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: TextField(
                            controller: _dur3Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'dur3',
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
                                value: _selectedVal2,
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
                                items: durationUnit.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVal2 = value as String;
                                  });
                                },
                              )))
                    ]),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _hdmy3Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'hdmy3',
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
                      controller: _rhController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'rh',
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
                      controller: _reportlinkController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'reportlink',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                            onPressed: () {
                              pickfile();
                            },
                            icon: const Icon(Icons.camera)),
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
                    // SizedBox(
                    //   height: 100,
                    //   child: Image.file(file!),
                    // ),
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
                            await _addItem();
                          }

                          if (id != null) {
                            await _updateItem(
                                id: id,
                                comp1: _comp1Controller.text,
                                dur1: _dur1Controller.text + " " + _selectedVal,
                                hdmy1: _hdmy1Controller.text,
                                comp2: _comp2Controller.text,
                                dur2:
                                    _dur2Controller.text + " " + _selectedVal1,
                                hdmy2: _hdmy2Controller.text,
                                comp3: _comp3Controller.text,
                                dur3:
                                    _dur3Controller.text + " " + _selectedVal2,
                                rh: _rhController.text,
                                reportlink: _reportlinkController.text,
                                hdmy3: _hdmy3Controller.text,
                                testdate: _testdateController.text,
                                entrydate: _entrydateController.text,
                                serno: _sernoController.text,
                                uploaded: 'false');
                          }
                          _idController.text = '';
                          _comp1Controller.text = '';
                          _hdmy1Controller.text = '';
                          _dur1Controller.text = '';
                          _entrydateController.text = '';
                          _comp2Controller.text = '';
                          file_path = '';
                          _dur2Controller.text = '';
                          _hdmy2Controller.text = '';
                          _comp3Controller.text = '';
                          _dur3Controller.text = '';
                          _rhController.text = '';
                          _reportlinkController.text = '';
                          _hdmy3Controller.text = '';

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
    if (item.text == 'Vitals') {
      Navigator.of(context).pushNamedAndRemoveUntil(notesroute, (_) => false);
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
        title: const Text('Complaints'),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              ...MenuItems.itemssecond.map(buildItem).toList(),
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
                                            "UPLOAD", 'second',
                                            constraints: Constraints(
                                                networkType:
                                                    NetworkType.connected),
                                            inputData: {
                                              'comp1': _journals[index]
                                                  ['comp1'],
                                              'dur1': _journals[index]['dur1'],
                                              'hdmy1': _journals[index]
                                                  ['hdmy1'],
                                              'comp2': _journals[index]
                                                  ['comp2'],
                                              'dur2': _journals[index]['dur2'],
                                              'hdmy2': _journals[index]
                                                  ['hdmy2'],
                                              'comp3': _journals[index]
                                                  ['comp3'],
                                              'dur3': _journals[index]['dur3'],
                                              'hdmy3': _journals[index]
                                                  ['hdmy3'],
                                              'rh': _journals[index]['rh'],
                                              'reportlink': _journals[index]
                                                  ['reportlink'],
                                              'testdate': _journals[index]
                                                  ['testdate'],
                                              'entrydate': _journals[index]
                                                  ['entrydate'],
                                              'serno': _journals[index]
                                                  ['serno'],
                                            });
                                        await _updateItem(
                                            id: _journals[index]['id'],
                                            comp1: _journals[index]['comp1'],
                                            dur1: _journals[index]['dur1'],
                                            hdmy1: _journals[index]['hdmy1'],
                                            comp2: _journals[index]['comp2'],
                                            dur2: _journals[index]['dur2'],
                                            hdmy2: _journals[index]['hdmy2'],
                                            comp3: _journals[index]['comp3'],
                                            dur3: _journals[index]['dur3'],
                                            hdmy3: _journals[index]['hdmy3'],
                                            rh: _journals[index]['rh'],
                                            reportlink: _journals[index]
                                                ['reportlink'],
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
                                      icon: const Icon(Icons.delete))
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
