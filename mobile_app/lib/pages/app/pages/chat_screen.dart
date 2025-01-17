import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/components/text_input/text_input_with_send.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:health_care/pages/app/additional/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';

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
            "AI")),
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
    Map<String, dynamic> res = await FirestoreDbService()
        .fetchChats(FirebaseAuth.instance.currentUser!.uid);
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

  void sendToAI(ChatModel chatModel) {
    /*
    
    AI API call
    
    */
    String d =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    final aiResponse = ChatModel("I got your msg", d, false, "AI");
    setState(() {
      _chatBubbles.add(ChatBubble(chatModel: aiResponse));
    });
    FirestoreDbService()
        .sendChats(FirebaseAuth.instance.currentUser!.uid, chatModel);
  }

  void onSend() async {
    String d =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";

    final chatModel = ChatModel(credentialController.text, d, true, "Me");

    Map<String, dynamic> res = await FirestoreDbService()
        .sendChats(FirebaseAuth.instance.currentUser!.uid, chatModel);
    if (res['success']) {
      //
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
      _chatBubbles.add(ChatBubble(chatModel: chatModel));
    });

    sendToAI(chatModel);
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
