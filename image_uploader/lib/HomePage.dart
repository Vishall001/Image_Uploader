import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool is_Uploaded = false;

  void showAlertDialog(ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Please select an image first')));
  }

  File? file;
  ImagePicker picker = ImagePicker();
  Future<void> pickImage() async {
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() {
        file = File(xFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> uploadToCloud(File imageFile) async {
      const url = 'https://codelime.in/api/remind-app-token';
      try {
        setState(() {
          is_Uploaded = true;
        });
        var stream = http.ByteStream(imageFile.openRead());
        stream.cast();
        var length = await imageFile.length();

        var uri = Uri.parse(url);

        var request = http.MultipartRequest("POST", uri);
        var multipartFile = http.MultipartFile('file', stream, length,
            filename: basename(imageFile.path));

        request.files.add(multipartFile);
        var response = await request.send();
        response.stream.transform(utf8.decoder).listen((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Image successfully uploaded"),
          ));
          setState(() {
            file = null;
            is_Uploaded = false;
          });
        });
      } catch (error) {
        print(error);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Image Uploader")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.all(20),
              height: 400,
              width: double.infinity,
              child: file != null
                  ? Image.file(
                      file!,
                    )
                  : Image.network(loadingBuilder: (BuildContext context,
                          Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/1362px-Placeholder_view_vector.svg.png'),
            ),
            TextButton(onPressed: pickImage, child: const Text("Open Gellery")),
            TextButton(
              onPressed: () => file != null
                  ? uploadToCloud(file!)
                  : showAlertDialog(context),
              child: is_Uploaded
                  ? CircularProgressIndicator()
                  : Text("Upload to Cloud"),
            ),
          ],
        ),
      ),
    );
  }
}
