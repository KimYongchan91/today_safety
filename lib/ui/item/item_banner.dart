import 'package:flutter/material.dart';

class ItemMainBanner extends StatelessWidget {
  const ItemMainBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),

      //todo ldj, 가로 사이즈 오버플로우 해결
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 70, height: 70, child: Image.asset('assets/images/images/13.jpg')),
          const SizedBox(width: 10,),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '안전은 가장 큰 자산입니다.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('오늘안전과 함께 오늘도 안전한 하루 되세요!'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
