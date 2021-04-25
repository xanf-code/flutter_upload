import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:html';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  String imgUrl;

  uploadToStorage() {
    InputElement input = FileUploadInputElement()..accept = 'image/*';
    FirebaseStorage fs = FirebaseStorage.instance;
    input.click();
    input.onChange.listen((event) {
      final file = input.files.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) async {
        var snapshot =
            await fs.ref().child('file_${DateTime.now()}').putBlob(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imgUrl = downloadUrl;
          debugPrint(imgUrl);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        return Scaffold(
          body: Column(
            children: [
              imgUrl == null
                  ? Placeholder(
                      fallbackHeight: 200,
                      fallbackWidth: 400,
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      child: CachedNetworkImage(
                        imageUrl: imgUrl,
                      ),
                    ),
              SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () => uploadToStorage(),
                child: Text("Upload"),
              ),
            ],
          ),
        );
      },
    );
  }
}
