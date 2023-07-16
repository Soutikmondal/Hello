import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class UploadSql extends StatefulWidget {
  String name;
  String stytolic;
  String dytolic;
  UploadSql(this.name, this.stytolic, this.dytolic, {super.key});

  @override
  State<UploadSql> createState() => _UploadSqlState();
}

class _UploadSqlState extends State<UploadSql> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = widget.name;
    _diatolicController.text = widget.dytolic;
    _stytolicController.text = widget.stytolic;
  }

  Future<void> insertRecord(String name, stytolic, diatolic) async {
    try {
      String uri = "http://10.0.2.2/project/insert_record.php";
      await http.post(Uri.parse(uri), body: {
        "name": name,
        "stytolic": stytolic,
        "dytolic": diatolic,
      });
    } catch (e) {
      print(e);
    }
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _stytolicController = TextEditingController();
  TextEditingController _diatolicController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Connectivity connectivity = Connectivity();
    return FutureBuilder(
      future: connectivity.checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.wifi) {
          return StreamBuilder<ConnectivityResult>(
            stream: connectivity.onConnectivityChanged,
            builder: (_, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Upload"),
                  backgroundColor: Colors.blue,
                ),
                body: Center(
                    child: (snapshot.data == ConnectivityResult.none)
                        ? const Center(
                            child: Text("CHECK YOUR INTERNET"),
                          )
                        : Column(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextField(
                                // enableSuggestions: false,
                                // autocorrect: false,
                                // keyboardType: TextInputType.emailAddress,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _stytolicController,
                                decoration: InputDecoration(
                                  hintText: 'Stytolic Pressure',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _diatolicController,
                                decoration: InputDecoration(
                                  hintText: 'Diatolic Pressure',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _diatolicController,
                                decoration: InputDecoration(
                                  hintText: '80',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _diatolicController,
                                decoration: InputDecoration(
                                  hintText: '97F',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _diatolicController,
                                decoration: InputDecoration(
                                  hintText: 'NIL',
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () async {
                                  return insertRecord(
                                      _nameController.text,
                                      _stytolicController.text,
                                      _diatolicController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 100, 194, 222),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text('Upload'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  return insertRecord(
                                      _nameController.text,
                                      _stytolicController.text,
                                      _diatolicController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 100, 194, 222),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text('Delete'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  return insertRecord(
                                      _nameController.text,
                                      _stytolicController.text,
                                      _diatolicController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 100, 194, 222),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text(
                                  'Update',
                                ),
                              ),
                            ],
                          )),
              );
            },
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text("Upload")),
            body: const Center(child: Text("You are not connected")),
          );
        }
      },
    );
  }
}
