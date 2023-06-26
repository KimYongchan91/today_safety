import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemMainLink extends StatefulWidget {
  const ItemMainLink({Key? key}) : super(key: key);

  @override
  State<ItemMainLink> createState() => _ItemMainLinkState();
}

class _ItemMainLinkState extends State<ItemMainLink> {
  final List<String> name = ['보건소', '산업재해', '노동청', '신고센터'];
  final List<Color> boxColor = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.yellowAccent];

  TextStyle listTxtStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
  @override
  Widget build(BuildContext context) {
    return Container(
      width:Get.width,

        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('관련링크',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),


            const SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Column(
                  children: [
                    Container(
                      width: 50,
                        height: 50,
                      color: boxColor[0],
                    ),
                    SizedBox(height: 10,),
                    Text(name[0], style: listTxtStyle,),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: boxColor[1],
                    ),
                    SizedBox(height: 10,),
                    Text(name[1],style: listTxtStyle,),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: boxColor[2],
                    ),
                    SizedBox(height: 10,),
                    Text(name[2],style: listTxtStyle,),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: boxColor[3],
                    ),
                    SizedBox(height: 10,),
                    Text(name[3],style: listTxtStyle,),
                  ],
                ),


              ],
            ),


            /*
            Expanded(
              child: ListView.builder(

                  scrollDirection: Axis.horizontal,
                  itemCount: name.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          ///아이콘
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: boxColor[index]),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          ///기관 이름
                          Text(
                         name[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
            ),

            */


          ],
        ));
  }
}
