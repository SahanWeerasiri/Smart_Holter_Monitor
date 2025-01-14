import 'package:health_care/components/text_input/text_input_with_send.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:health_care/pages/app/additional/chat_bubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatBubble> _chatBubbles = [
    ChatBubble(
        chatModel: ChatModel("msg1", "2024-01-01 11:01:14", false, "AI")),
  ];
  bool _isLoading = true; // Loading state
  final CredentialController credentialController = CredentialController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    // final arguments =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // if (arguments == null) {
    //   Navigator.pop(context); // Navigate back if no arguments are passed.
    //   return;
    // }

    setState(() {
      _isLoading = false;
    });
  }

  void onSend() {
    String d =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    setState(() {
      _chatBubbles.add(ChatBubble(
          chatModel: ChatModel(credentialController.text, d, true, "Me")));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        color: CustomColors().blue,
      ));
    }
    return Container(
      color: StyleSheet().uiBackground,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatBubbles.length,
              itemBuilder: (context, index) {
                return _chatBubbles[index];
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextInputWithSend(
                  inputController: credentialController,
                  hint: "Message",
                  hintColor: StyleSheet().greyHint,
                  textColor: StyleSheet().text,
                  iconColor: StyleSheet().chatIcon,
                  fontSize: AppSizes().getBlockSizeHorizontal(5),
                  shadowColor: StyleSheet().textBackground,
                  enableBorderColor: StyleSheet().disabledBorder,
                  focusedBorderColor: StyleSheet().enableBorder,
                  icon: Icons.message,
                  typeKey: CustomTextInputTypes().text,
                  onSend: onSend)),
        ],
      ),
    );
  }
}
