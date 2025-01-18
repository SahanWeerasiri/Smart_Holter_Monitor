import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_web/components/text_input/text_input_with_send.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:health_care_web/pages/app/additional/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';

class ChatScreen extends StatefulWidget {
  final User? user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatBubble> _chatBubbles = [
    ChatBubble(
        chatModel: ChatModel(
            "Hi!\nI'm Smart Care AI Agent.\nWhat is your problem?",
            "2024-01-01 11:01:14",
            false,
            "AI",
            "0")),
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

  void _initializeData() async {
    Map<String, dynamic> res =
        await FirestoreDbService().fetchChats(widget.user!.uid);
    if (res['success']) {
      setState(() {
        final tempChatBubbles = res['data'] as List<ChatModel>;
        for (var element in tempChatBubbles) {
          _chatBubbles.add(ChatBubble(chatModel: element));
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void sendToAI(ChatModel chatModel) async {
    /*
    
    AI API call
    
    */
    String d =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    final aiResponse = ChatModel("I got your msg", d, false, "AI", "0");

    Map<String, dynamic> res =
        await FirestoreDbService().sendChats(widget.user!.uid, aiResponse);

    if (res['success']) {
      aiResponse.chatId = res['key'];
      setState(() {
        _chatBubbles.add(ChatBubble(chatModel: aiResponse));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void onSend() async {
    String d =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";

    final chatModel = ChatModel(credentialController.text, d, true, "Me", "0");

    Map<String, dynamic> res =
        await FirestoreDbService().sendChats(widget.user!.uid, chatModel);
    if (res['success']) {
      chatModel.chatId = res['key'];
      setState(() {
        _chatBubbles.add(ChatBubble(chatModel: chatModel));
      });

      sendToAI(chatModel);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void onClear() async {
    Map<String, dynamic> res =
        await FirestoreDbService().deleteChats(widget.user!.uid, _chatBubbles);
    if (res['success']) {
      setState(() {
        _chatBubbles.clear();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        color: StyleSheet().btnBackground,
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
                onSend: onSend,
                onClear: onClear,
              )),
        ],
      ),
    );
  }
}
