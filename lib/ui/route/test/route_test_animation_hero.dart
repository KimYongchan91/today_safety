import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check_list.dart';

import '../../../const/value/fuc.dart';

class RouteTestAnimationHero extends StatefulWidget {
  final ModelCheckList modelCheckList;

  const RouteTestAnimationHero(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  State<RouteTestAnimationHero> createState() => _RouteTestHeroState();
}

class _RouteTestHeroState extends State<RouteTestAnimationHero> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                itemCount: widget.modelCheckList.listModelCheck.length,
                itemBuilder: (context, index) => SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    getPathCheckImage(widget.modelCheckList.listModelCheck[index]),
                    width: 50,
                    height: 50,
                  ),
                ),
                scrollDirection: Axis.horizontal,
              ),
            ),
            Hero(
                tag: "help",
                child: Card(
                  child: InkWell(
                      onTap: () {
                        /*          showDialog(
                          context: context,
                          builder: (context) => _Dialog(),
                        );*/

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (_, __, ___) => const _Dialog(),
                          ),
                        );
                      },
                      child: const Icon(Icons.help)),
                )),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        child: Hero(tag: "help", child: Icon(Icons.help)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _Dialog(),
          );
        },
      ),*/
    );
  }
}

class _Dialog extends StatefulWidget {
  const _Dialog({Key? key}) : super(key: key);

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  CountDownController countDownController = CountDownController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      countDownController.start();
    });
  }

  @override
  void dispose() {
    super.dispose();
    countDownController.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x33333333), //const Color(0x4D2980b9),
      body: SafeArea(
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },

          ///전체 화면
          ///dialog 밖을 클릭할 경우 닫히도록 하기 위해 존재
          child: Container(
            width: Get.width,
            height: Get.height,
            child: Center(
              child: InkWell(
                onTap: () {},

                ///실질적인 dialog 역할 하는 컨테이너
                child: Container(
                  width: Get.width * 0.8,
                  height: Get.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, //New
                          blurRadius: 15.0,
                          offset: Offset(10, 10))
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularCountDownTimer(
                          duration: 5,
                          initialDuration: 0,
                          controller: countDownController,
                          width: 30,
                          height: 30,
                          ringColor: Colors.grey[300]!,
                          ringGradient: null,
                          fillColor: Colors.purpleAccent[100]!,
                          fillGradient: null,
                          backgroundColor: Colors.white,
                          backgroundGradient: null,
                          strokeWidth: 20.0,
                          strokeCap: StrokeCap.round,
                          textStyle:
                              TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                          textFormat: CountdownTextFormat.S,
                          isReverse: true,
                          isReverseAnimation: true,
                          isTimerTextShown: false,
                          onStart: () {
                            debugPrint('Countdown Started');
                          },
                          onComplete: () {
                            debugPrint('Countdown Ended');
                            Navigator.pop(context);
                          },
                          onChange: (String timeStamp) {
                            debugPrint('Countdown Changed $timeStamp');
                          },
                          timeFormatterFunction: (defaultFormatterFunction, duration) {
                            if (duration.inSeconds == 0) {
                              return "Start";
                            } else {
                              return Function.apply(defaultFormatterFunction, [duration]);
                            }
                          },
                        ),
                        const Hero(
                          tag: "help",
                          child: Card(
                            child: Icon(
                              Icons.help,
                              size: 48,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('알겠어요.'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
