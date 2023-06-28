import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/dialog/dialog_help_user_check_hostory_state.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/route/route_map_detail.dart';
import 'package:today_safety/ui/route/route_user_check_history_detail.dart';

import '../../const/value/color.dart';
import '../../const/value/layout_main.dart';

const double sizeCheckImage = 60;

enum ItemUserCheckHistoryBigEmptyType { notLogin, empty }

///메인 루트에서 내 인증서를 보여줄 때 사용
///인증서가 없을 때임
class ItemUserCheckHistoryBigEmpty extends StatelessWidget {
  final ItemUserCheckHistoryBigEmptyType itemUserCheckHistoryBigEmptyType;
  final void Function()? onTap;
  final double padding;

  const ItemUserCheckHistoryBigEmpty(this.itemUserCheckHistoryBigEmptyType, {this.onTap, this.padding = 0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///인증서 영역
            InkWell(
              onTap: onTap,
              child: AspectRatio(
                aspectRatio: aspectRatioMainItemUserCheckHistoryBig1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.exclamationTriangle,
                          size: 100,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Text(
                          itemUserCheckHistoryBigEmptyType == ItemUserCheckHistoryBigEmptyType.notLogin
                              ? '로그인하고 내가 받은 인증서를 확인해 보세요.'
                              : '아직 받은 인증서가 없어요.',
                          style: _textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
