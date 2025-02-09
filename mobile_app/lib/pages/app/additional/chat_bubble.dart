import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatModel chatModel;
  const ChatBubble({super.key, required this.chatModel});
  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return SizedBox(
        width: AppSizes().getScreenWidth() / 3 * 2,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: chatModel.isSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: chatModel.isSender
                          ? StyleSheet().sendChatBuble1
                          : StyleSheet().recieveChatBuble1,
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 6,
                            color: Colors.black,
                            spreadRadius: BorderSide.strokeAlignCenter,
                            offset: Offset(2, 2))
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: chatModel.isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatModel.name,
                              style: TextStyle(
                                  color: chatModel.isSender
                                      ? StyleSheet().sendChatBuble2
                                      : StyleSheet().recieveChatBuble2,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                                width: AppSizes().getBlockSizeHorizontal(45),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: chatModel.isSender
                                      ? StyleSheet().sendChatBuble2
                                      : StyleSheet().recieveChatBuble2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: chatModel.isSender
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        chatModel.msg,
                                        style: TextStyle(
                                            color: chatModel.isSender
                                                ? StyleSheet().sendChatBuble1
                                                : StyleSheet()
                                                    .recieveChatBuble1,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizes()
                                                .getBlockSizeHorizontal(5)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  )),
            )
          ],
        ));
  }
}

class ChatModel {
  final String msg;
  final String timestamp;
  final bool isSender;
  final String name;
  String chatId = "";
  ChatModel(this.msg, this.timestamp, this.isSender, this.name, this.chatId);
}
