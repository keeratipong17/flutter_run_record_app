// ignore_for_file: sort_child_properties_last

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_run_record_app/models/run.dart';

class UpDelRunUi extends StatefulWidget {
  //สร้างตัวแปรรับข้อมูลเพื่อจะมาแสดงที่หน้าจอ
  int? runId;
  String? runLocation;
  double? runDistance;
  int? runtime;

  UpDelRunUi({
    super.key,
    this.runId,
    this.runLocation,
    this.runDistance,
    this.runtime,
  });

  @override
  State<UpDelRunUi> createState() => _UpDelRunUiState();
}

class _UpDelRunUiState extends State<UpDelRunUi> {
  //สร้างตัวควบคุม TexField
  TextEditingController runLocationCtrl = TextEditingController();
  TextEditingController runDistanceCtrl = TextEditingController();
  TextEditingController runTimeCtrl = TextEditingController();

  //แสดงคำเตือน
  Future<void> _showWarningDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('คำเตือน'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _ShowResultDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ผลการทำงาน'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    runLocationCtrl.text = widget.runLocation!;
    runDistanceCtrl.text = widget.runDistance.toString();
    runTimeCtrl.text = widget.runtime.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'แก้ไขลบการวิ่งของฉัน',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 40.0,
          right: 40.0,
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Image.asset(
                'assets/images/running.png',
                width: 150.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'สถานที่วิ่ง',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: runLocationCtrl,
                decoration: InputDecoration(
                  hintText: 'กรุณากรอกสถานที่วิ่ง',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ระยะทางที่วิ่ง (กิโลเมตร)',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: runDistanceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'กรุณากรอกระยะทางที่วิ่ง',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'เวลาที่ใช้ในการวิ่ง (นาที)',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: runTimeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'กรุณากรอกเวลาที่ใช้ในการวิ่ง',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (runLocationCtrl.text.isEmpty) {
                    await _showWarningDialog("กรุณากรอกสถานที่วิ่ง");
                  } else if (runDistanceCtrl.text.isEmpty) {
                    await _showWarningDialog("กรุณากรอกระยะทางที่วิ่ง");
                  } else if (runTimeCtrl.text.isEmpty) {
                    await _showWarningDialog("กรุณากรอกเวลาในการวิ่ง");
                  } else {
                    // แพ็กข้อมูลที่ส่ง
                    Run run = Run(
                      runLocation: runLocationCtrl.text,
                      runDistance: double.parse(runDistanceCtrl.text),
                      runTime: int.parse(runTimeCtrl.text),
                    );
                    // ส่งข้อมูลโดยเอาข้อมูลที่ส่งมาทำ JSON
                    final result = await Dio().put(
                      'http://192.168.31.196:5050/api/run/${widget.runId}',
                      data: run.toJson(),
                    );
                    // ตรวจสอบผลการทำงาน Result
                    if (result.statusCode == 200) {
                      await _ShowResultDialog('แก้ไขการวิ่งเรียบร้อยแล้ว')
                          .then((value) {
                        Navigator.pop(context);
                      });
                    } else {
                      await _showWarningDialog('ไม่สามารถแก้ไขการวิ่งได้');
                    }
                  }
                },
                child: Text(
                  'แก้ไขการวิ่ง',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(
                    MediaQuery.of(context).size.width,
                    60.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await Dio().delete(
                    'http://192.168.31.196:5050/api/run/${widget.runId}',
                  );
                  // ตรวจสอบผลการทำงาน Result
                  if (result.statusCode == 200) {
                    await _ShowResultDialog('ลบการวิ่งเรียบร้อยแล้ว')
                        .then((value) {
                      Navigator.pop(context);
                    });
                  } else {
                    await _showWarningDialog('ไม่สามารถลบการวิ่งได้');
                  }
                },
                child: Text(
                  'ลบการวิ่ง',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(
                    MediaQuery.of(context).size.width,
                    60.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
