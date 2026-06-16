import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  // static const  List<String> imgList = [
  //   'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  //   'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  //   'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  //   'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  //   'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  //   'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  // ];
  static const List<String> imgList = [
    'assets/images/intro/image3.png',
    'assets/images/intro/image4.png',
    'assets/images/intro/image5.png'
  ];

  const IntroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildSlider(context),
    );
  }

  SingleChildScrollView buildSlider(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          //height: MediaQuery.of(context).size.height,
          color: const Color(0xFFFFFFFF),
          margin: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height * .10, 0, 10),
          child: CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.8,
              viewportFraction: 1,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              initialPage: 1,
              autoPlay: true,
            ),
            // ignore: avoid_unnecessary_containers
            items: imgList
                .map((item) => Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Image.asset(
                          item,
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                        )),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: const Text(
                            "هو ببساطة نص شكلي",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Tajawal-Bold',
                                color: Color(0xFF243060),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: const Text(
                            "ويُستخدم في صناعات المطابع ودور النشر. كان لوريم إيبسوم ولايزال المعيار للنص الشكلي منذ القرن الخامس عشر عندما قامت مطبعة مجهولة برص مجموعة من الأحرف بشكل عشوائي أخذتها من نص",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Tajawal-Reqular',
                                color: Color(0xFF99A7FE),
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    )))
                .toList(),
          ),
        ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                backgroundColor: const Color(0xFFFE7064),
                foregroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: const Text(
              'ابدآ',
              style: TextStyle(
                  fontFamily: 'Tajawal-Bold',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {},
          ),
        ),
      ],
    ));
  }
}
