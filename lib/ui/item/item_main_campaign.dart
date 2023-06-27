import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemMainCampaign extends StatelessWidget {
  const ItemMainCampaign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: Get.width/2 ,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.orange
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Text('우롸모암암암',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

          ],
        ),
      ),
    );
  }
}
