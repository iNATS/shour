// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NewRequestScreen extends StatelessWidget {
  const NewRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.9,
        backgroundColor: Colors.white,
        //shadowColor: Color.fromARGB(0, 216, 216, 216),
        toolbarHeight: 50, // default is 56
        //toolbarOpacity: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.list_outlined,
                color: Color(0xFF243060),
                size: 32,
              )),
        ),
        //leadingWidth: 150, // default is 56
        title: Center(
            child: Text(
          'شور',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: Color(0xFFE9605A),
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 24),
        )),
        actions: [
          // Container(
          //   width: 30,
          //   child: Image.asset(
          //     'assets/images/profile_pic.png',
          //   ),
          // ),
          Icon(
            Icons.more_vert,
            color: Color(0xFF243060),
            size: 32,
          ),
          Icon(
            Icons.more_vert,
            color: Color(0xFF243060),
            size: 32,
          ),
          Icon(
            Icons.more_vert,
            color: Color(0xFF243060),
            size: 32,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "طلب جديد   ",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Tajawal',
                          color: Color(0xFFE9605A),
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF242F64), width: 0.09),
                        borderRadius: BorderRadius.circular(15)),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'عنوان الطلب',
                    hintStyle: TextStyle(
                        color: Color(0xFF242F64),
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.normal)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextField(
                textAlign: TextAlign.right,
                maxLines: 8,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF242F64), width: 0.09),
                        borderRadius: BorderRadius.circular(15)),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'تفاصيل الطلب',
                    hintStyle: TextStyle(
                        color: Color(0xFF242F64),
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.normal)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 10),
                    backgroundColor: const Color(0xFFFE7064),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Text(
                  ' صورة الطلب',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text('الاقسام',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color(0xFF242F64),
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          fontSize: 18))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RadioListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Text(
                  "Animals",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFF242F64),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                value: "1",
                groupValue: "1",
                onChanged: (value) {
                  // setState(() {
                  //     gender = value.toString();
                  // });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RadioListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Text(
                  "Animals",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFF242F64),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                value: "2",
                groupValue: "1",
                onChanged: (value) {
                  // setState(() {
                  //     gender = value.toString();
                  // });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RadioListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Text(
                  "Animals",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFF242F64),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                value: "3",
                groupValue: "1",
                onChanged: (value) {
                  // setState(() {
                  //     gender = value.toString();
                  // });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RadioListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Text(
                  "Animals",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFF242F64),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                value: "3",
                groupValue: "1",
                onChanged: (value) {
                  // setState(() {
                  //     gender = value.toString();
                  // });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RadioListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Text(
                  "Animals",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFF242F64),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                value: "3",
                groupValue: "1",
                onChanged: (value) {
                  // setState(() {
                  //     gender = value.toString();
                  // });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 10),
                    backgroundColor: const Color(0xFFFE7064),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Text(
                  'موقع الطلب  ',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 10),
                    backgroundColor: const Color(0xFF242F64),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text(
                  ' ارسال  ',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFE7064),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Drawer Header'),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context); // close it
              },
            ),
          ],
        ),
      ),
    );
  }
}
