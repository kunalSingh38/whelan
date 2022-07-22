import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/constants.dart';

import 'checklist_screen.dart';
import 'job_pagination.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loggedIn = false;
  bool _next = false;
  bool firstShow = false;
  final splashDelay = 3;
  String formattedDate1 = "";
  String lastVisitDate = "";
  String splash_screen = "";
  String client_logo = "";
  String appName = "";
  bool isLoading = true;
  String tncLink = "";
  String tnc_text = "";
  // String collection_tnc = "";
  bool checkbox = false;
  Future<void> loadConfig() async {
    var response = await http.get(Uri.parse(URL + 'config'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $STATIC_BARIER'
    });
    print(URL + 'config');
    print(response.body);
    if (jsonDecode(response.body)['status'] == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("config", jsonEncode(jsonDecode(response.body)));

      var data = pref.getString("config");

      setState(() {
        client_logo = jsonDecode(data)['data']['client_logo'].toString();
        splash_screen = jsonDecode(data)['data']['splash_screen'].toString();
        appName = jsonDecode(data)['data']['app_name'].toString();
        tncLink = jsonDecode(data)['data']['tnc_url'].toString();
        // collection_tnc = jsonDecode(data)['data']['collection_tnc'].toString();
        tnc_text = jsonDecode(data)['data']['tnc_text'].toString();
        pref.setString(
            "tipping_tnc", jsonDecode(data)['data']['tipping_tnc'].toString());

        pref.setString("collection_tnc",
            jsonDecode(data)['data']['collection_tnc'].toString());
        pref.setString(
            "html_currency_code",
            jsonDecode(data)['data']['currency']['html_currency_code']
                .toString());
        pref.setString("vehicle_no",
            jsonDecode(data)['data']['collection_tnc'].toString());
        pref.setString(
            "yellow_color",
            "0xFF" +
                jsonDecode(response.body)['data']['color1']
                    .toString()
                    .replaceFirst("#", ""));
        pref.setString(
            "red_color",
            "0xFF" +
                jsonDecode(response.body)['data']['color2']
                    .toString()
                    .replaceFirst("#", ""));
      });
      getDeviceId().then((di) {
        _checkDevice(di).then((value) {
          if (value == 200) {
            Fluttertoast.showToast(
                msg: "Device Registered.",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT);
            _checkLoggedIn();
          } else {
            showPhotoCaptureOptions(di);
          }
        });
      });
    } else {
      Fluttertoast.showToast(
          msg: "Configuration data is not loading. Please try again later.");
    }
    setState(() {
      isLoading = false;
    });
  }

  int red = 0;
  int yellow = 0;
  @override
  void initState() {
    super.initState();

    loadConfig();

    // checkIsTodayVisit();
  }

  Future<int> _checkDevice(String deviceId) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $STATIC_BARIER'
    };
    print(URL + 'access-code/$deviceId');
    var uri = Uri.parse(URL + 'access-code/$deviceId');
    var response = await http.get(
      uri,
      headers: headers,
    );

    print(response.body);
    return response.statusCode;
  }

  String os = "";
  String model = "";
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      var device_Id = await deviceInfoPlugin.androidInfo;
      setState(() {
        os = "android";
        model = device_Id.model.toString();
      });
      return device_Id.androidId.toString();
    } else {
      var device_Id = await deviceInfoPlugin.iosInfo;
      setState(() {
        os = "ios";
        model = device_Id.model.toString();
      });
      return device_Id.identifierForVendor.toString();
    }
  }

  _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _isLoggedIn = prefs.getBool('logged_in');
    if (_isLoggedIn == true) {
      setState(() {
        _loggedIn = _isLoggedIn;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
    // checkIsTodayVisit();
    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 30, fontWeight: FontWeight.w300, color: Colors.black);
  void navigationPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => homeOrLog()));
  }

  // checkIsTodayVisit() async {
  //   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //   SharedPreferences prefs = await _prefs;
  //   lastVisitDate = prefs.get("mDateKey");
  //   if (prefs.getBool("firstShow") != null) {
  //     firstShow = prefs.getBool("firstShow");
  //   }

  //   var now = new DateTime.now();
  //   var formatter = new DateFormat('dd-MMM-yyyy');
  //   String toDayDate = formatter.format(now);

  //   if (toDayDate == lastVisitDate) {
  //     print(lastVisitDate);
  //     setState(() {
  //       _next = true;
  //     });
  //   } else {
  //     print(lastVisitDate);
  //     if (lastVisitDate == null) {
  //       if (firstShow) {
  //         setState(() {
  //           _next = true;
  //         });
  //       } else {
  //         setState(() {
  //           _next = false;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _next = false;
  //       });
  //     }

  //     /* if(firstShow) {
  //       prefs.setString("mDateKey", toDayDate);
  //     }
  //     else{
  //       prefs.setString("mDateKey", "");
  //     }*/
  //   }
  //   _loadWidget();
  // }

  Widget homeOrLog() {
    if (this._loggedIn) {
      var obj = 0;
      return JobsScreen11();
    } else {
      return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: InkWell(
              child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.40,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(splash_screen),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: Image.network(
                              client_logo,
                              scale: 10,
                            ),
                          ),
                          Text(
                            appName.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          TextButton(
                              onPressed: () {
                                getDeviceId().then((di) {
                                  _checkDevice(di).then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (value == 200) {
                                      Fluttertoast.showToast(
                                          msg: "Device Registered.",
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_SHORT);
                                      _checkLoggedIn();
                                    } else {
                                      showPhotoCaptureOptions(di);
                                    }
                                  });
                                });
                              },
                              child: Text("Reset",
                                  style: TextStyle(color: Colors.blue)))
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: MaterialButton(
                            onPressed: () => {},
                            child: Text("Loading...", style: normalText),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          );
  }

  TextEditingController accessCode = TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  Future<void> showPhotoCaptureOptions(String deviceId) async {
    setState(() {
      accessCode.text = "";
    });
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: key,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
                              child: Text(
                                'YOUR DEVICE IS NOT REGISTERED WITH US.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            // Row(
                            //   children: [
                            //     Checkbox(
                            //         value: checkbox,
                            //         activeColor: Colors.blue,
                            //         onChanged: (val) {
                            //           setState(() {
                            //             checkbox = !checkbox;
                            //           });
                            //         }),
                            //     Text(collection_tnc.toString())
                            //   ],
                            // ),

                            TextFormField(
                              controller: accessCode,
                              // autofocus: true,
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 10, 10, 10),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: "Enter Access Code",
                                  counterText: ""),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Row(
                            //   children: [
                            //     InkWell(
                            //       onTap: () {
                            //         setState(() {
                            //           checkbox = !checkbox;
                            //         });
                            //       },
                            //       child: Checkbox(
                            //           value: checkbox,
                            //           activeColor: Colors.blue,
                            //           onChanged: (val) {
                            //             setState(() {
                            //               checkbox = !checkbox;
                            //             });
                            //           }),
                            //     ),
                            //     InkWell(
                            //       onTap: () {
                            //         launch(tncLink);
                            //       },
                            //       child: Text(
                            //         tnc_text.toString(),
                            //         style: TextStyle(
                            //             color: Colors.blue,
                            //             fontWeight: FontWeight.bold),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // ListTile(
                            //   minLeadingWidth: 1,
                            //   leading: InkWell(
                            //     onTap: () {
                            //       setState(() {
                            //         checkbox = !checkbox;
                            //       });
                            //     },
                            //     child: Checkbox(
                            //         value: checkbox,
                            //         activeColor: Colors.blue,
                            //         onChanged: (val) {
                            //           setState(() {
                            //             checkbox = !checkbox;
                            //           });
                            //         }),
                            //   ),
                            //   title: TextButton(
                            //       onPressed: () {
                            //         launch(tncLink);
                            //       },
                            //       child: Text(
                            //         tnc_text.toString(),
                            //         style: TextStyle(color: Colors.blue),
                            //       )),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    left: 12,
                                    right: 12),
                                child: SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        style: ButtonStyle(
                                            backgroundColor:
                                                // checkbox
                                                //     ?
                                                MaterialStateProperty.all(
                                                    Colors.green[600]),
                                            // : MaterialStateProperty.all(
                                            //     Colors.green[200]),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ))),
                                        onPressed: () async {
                                          // if (checkbox) {
                                          if (key.currentState.validate()) {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text("Loading"),
                                                      content: SizedBox(
                                                        height: 30,
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                    ));
                                            print(URL + 'access-code/create');
                                            print(jsonEncode({
                                              "device_id": deviceId.toString(),
                                              "access_code":
                                                  accessCode.text.toString(),
                                              "os": os,
                                              "model": model
                                            }));
                                            Map<String, String> headers = {
                                              'Accept': 'application/json',
                                              'Authorization':
                                                  'Bearer $STATIC_BARIER'
                                            };
                                            var uri = Uri.parse(
                                                URL + 'access-code/create');
                                            var response = await http.post(uri,
                                                headers: headers,
                                                body: {
                                                  "device_id":
                                                      deviceId.toString(),
                                                  "access_code": accessCode.text
                                                      .toString(),
                                                  "os": os,
                                                  "model": model
                                                });
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            print(response.body);
                                            print(response.statusCode);
                                            if (response.statusCode == 201) {
                                              Fluttertoast.showToast(
                                                  msg: "Device ID Registered.",
                                                  gravity: ToastGravity.CENTER,
                                                  toastLength:
                                                      Toast.LENGTH_LONG);
                                              _checkLoggedIn();
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: Text(
                                                                "Incorrect Access Code"),
                                                            content: Text(
                                                                "Access code is wrong. Please try again"),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    getDeviceId()
                                                                        .then(
                                                                            (di) {
                                                                      print(di
                                                                          .toString());
                                                                      _checkDevice(
                                                                              di)
                                                                          .then(
                                                                              (value) {
                                                                        if (value ==
                                                                            200) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Device Registered.",
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              toastLength: Toast.LENGTH_SHORT);
                                                                          _checkLoggedIn();
                                                                        } else {
                                                                          showPhotoCaptureOptions(
                                                                              di);
                                                                        }
                                                                      });
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    "Try Again",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ))
                                                            ],
                                                          ));

                                              // Fluttertoast.showToast(
                                              //     msg:
                                              //         "Access code is wrong. Please try again",
                                              //     gravity: ToastGravity.CENTER,
                                              //     toastLength: Toast.LENGTH_LONG);
                                            }
                                          }
                                          // } else {
                                          //   Fluttertoast.showToast(
                                          //       msg:
                                          //           "Please check the check box");
                                          // }
                                        })))
                          ]),
                    ));
              },
            ));
  }
}
