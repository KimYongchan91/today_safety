import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ItemNotice extends StatelessWidget {
  const ItemNotice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: Get.width,
        height: 70,
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: const FaIcon(
                  FontAwesomeIcons.bullhorn,
                  color: Colors.redAccent,
                )),
            const SizedBox(
              width: 20,
            ),
            const Expanded(
                child: Text(
              '공지사항',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            )),
            const FaIcon(
              FontAwesomeIcons.angleRight,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
