import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import './add_via_text.dart';

class AddHighlight extends StatefulWidget {
  @override
  _AddHighlightState createState() => _AddHighlightState();
}

class _AddHighlightState extends State<AddHighlight> {
  File _image;

  String text = '';

  VisionText _extractedText;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

    final image = FirebaseVisionImage.fromFile(_image);

    final textRecognizer = FirebaseVision.instance.textRecognizer();

    _extractedText = await textRecognizer.processImage(image);

    String str = _extractedText.text;

    RegExp reg = new RegExp(r'(?<=\[)[^\]\[]*(?=])');

    RegExpMatch match = reg.firstMatch(str);

    text = str.substring(match.start, match.end);

    print(text);

    Navigator.of(context)
        .pushNamed(AddViaText.routeName, arguments: {'highlight': text});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                size: 70,
              ),
              Text(
                "Mark the text between square\n brackets [] to capture via photo",
                textAlign: TextAlign.center,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                      minWidth: 120,
                      padding: EdgeInsets.all(12),
                      color: Colors.lightBlue[800],
                      onPressed: () {
                        Navigator.of(context).pushNamed(AddViaText.routeName);
                      },
                      child: Text(
                        'Add via text',
                        style: TextStyle(color: Colors.white),
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  FlatButton(
                      minWidth: 120,
                      padding: EdgeInsets.all(12),
                      color: Colors.teal[600],
                      onPressed: _pickImage,
                      child: Text('Add via photo',
                          style: TextStyle(color: Colors.white)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
