import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(new MaterialApp(home: new MyApp()));
}

class MyApp extends StatefulWidget {
  static const String id = 'popup_form';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final popupKey = GlobalKey<FormState>();
  final binIdController = TextEditingController();
  final binAddressController = TextEditingController();
  final remarksController = TextEditingController();
  bool _loading = false;

  Future<Position> getLocation() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
  }

  Future<http.Response> sendData(binData) async {
    log('data:$binData');

    var url = 'http://192.168.10.34:3000/api/bins/new';
    Map<String, String> headers = {"Content-type": "application/json"};

    return await http.post(url, headers: headers, body: jsonEncode(binData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Positioned(
                          right: -40.0,
                          top: -40.0,
                          child: InkResponse(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: CircleAvatar(
                              child: Icon(Icons.close),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                        Form(
                          key: popupKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                controller: binIdController,
                                decoration:
                                    InputDecoration(labelText: 'Bin ID'),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some number';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: binAddressController,
                                decoration:
                                    InputDecoration(labelText: 'Address'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: remarksController,
                                decoration:
                                    InputDecoration(labelText: 'Remarks'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              RaisedButton(
                                  child: Text('Add Bin'),
                                  onPressed: () async {
                                    setState(() => _loading = true);

                                    Position position = await getLocation();

                                    if (popupKey.currentState.validate()) {
                                      var formData = {
                                        'bin_id':
                                            int.parse(binIdController.text),
                                        'bin_address':
                                            binAddressController.text,
                                        'remarks': remarksController.text,
                                        'latitude': position.latitude,
                                        'longitude': position.longitude,
                                        'image': null,
                                        "employee_id": 2,
                                      };

                                      http.Response resp =
                                          await sendData(formData);
                                      log('data: hello');

                                      setState(() => _loading = false);
                                      if (resp.statusCode == 201) {
                                        String message =
                                            jsonDecode(resp.body)['message'];
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  title: Text('Success!'),
                                                  content: Text(message),
                                                ));

                                        binIdController.clear();
                                        binAddressController.clear();
                                        remarksController.clear();

//                        Navigator.push(context, MaterialPageRoute(builder: (context) =>EmpMap()));

                                      } else {
                                        Scaffold.of(context).showSnackBar(SnackBar(
                                            content: Text(
                                                "Oops! Something went wrong.")));
                                      }
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
          child: Text("Open Popup"),
        ),
      ),
    );
  }
}
