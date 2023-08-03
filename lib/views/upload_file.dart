import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  String? file_name;
  PlatformFile? picked_file;
  File? file_to_display;
  FilePickerResult? result;
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
          file_to_display = File(picked_file!.path.toString());
          _file = file_to_display!.readAsBytesSync();
        });
      }
    } catch (e) {
      log("error $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload File"),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
                onPressed: () {
                  pickfile();
                },
                child: const Text("Pick a File")),
          ),
          const SizedBox(
            height: 10,
          ),
          if (picked_file != null)
            SizedBox(
              height: 400,
              width: 300,
              child: Image.file(file_to_display!),
            ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(onPressed: () {}, child: const Text("Upload"))
        ],
      ),
    );
  }
}
