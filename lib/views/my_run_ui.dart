// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_run_record_app/models/run.dart';
import 'package:flutter_run_record_app/views/insert_run_ui.dart';
import 'package:flutter_run_record_app/views/up_del_run_ui.dart';

class MyRunUi extends StatefulWidget {
  const MyRunUi({super.key});

  @override
  State<MyRunUi> createState() => _MyRunUiState();
}

class _MyRunUiState extends State<MyRunUi> {
  // สร้างตัวแปรเพื่อเก็บข้อมูลการวิ่งที่ดึงมาจากฐานข้อมูลผ่าน API
  late Future<List<Run>> myRuns;

  Future<List<Run>> fetchMyRuns() async {
    try {
      final response = await Dio().get('http://192.168.31.196:5050/api/run');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'] as List<dynamic>;
        return data.map((json) => Run.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load runs');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load runs: ${e.message}');
    }
  }

  @override
  void initState() {
    // ตอนหน้าจอถูกเปิด ให้ไปดึงข้อมูลแล้วเก็บในตัวแปร myRun
    myRuns = fetchMyRuns();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'การวิ่งของฉัน',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/Running.png',
              width: 150,
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<Run>>(
              future: myRuns,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Run> runs = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: runs.length,
                      itemBuilder: (context, index) {
                        Run run = runs[index];
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpDelRunUi(
                                  runId: run.runId,
                                  runLocation: run.runLocation,
                                  runDistance: run.runDistance,
                                  runtime: run.runTime,
                                ),
                              ),
                            ).then((value) {
                              setState(() {
                                myRuns = fetchMyRuns();
                              });
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          title: Text(
                            'สถานที่วิ่ง: ' + run.runLocation!,
                          ),
                          subtitle: Text(
                            'ระยะทางวิ่ง: ' +
                                run.runDistance!.toString() +
                                ' km',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.black),
                          tileColor:
                              index % 2 == 0 ? Colors.white : Colors.grey[200],
                        );
                      },
                    ),
                  );
                } else {
                  return const Text('No runs found.');
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertRunUi(),
            ),
          ).then((value) {
            setState(() {
              myRuns = fetchMyRuns();
            });
          });
        },
        label: Text(
          "เพิ่มการบันทึกการวิ่ง",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        icon: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
