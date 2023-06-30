
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                              : '유효한 인증서가 없어요.',
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
