import 'package:flutter/material.dart';

class ItemMainLink extends StatefulWidget {
  const ItemMainLink({Key? key}) : super(key: key);

  @override
  State<ItemMainLink> createState() => _ItemMainLinkState();
}

class _ItemMainLinkState extends State<ItemMainLink> {
  final List<String> name = ['보건소', '산업재해', '노동청', '신고센터'];
  final List<Color> boxColor = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.yellowAccent];

  @override
  Widget build(BuildContext context) {
    return Container(
    height: 200,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('관련링크',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),


            const SizedBox(height: 20,),

            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: name.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
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
          ],
        ));
  }
}
