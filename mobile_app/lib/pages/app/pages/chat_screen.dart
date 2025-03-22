// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:health_care/components/text_input/text_input_with_send.dart';
// import 'package:health_care/constants/consts.dart';
// import 'package:health_care/controllers/textController.dart';
import 'package:health_care/models/user.dart';
import 'package:health_care/pages/app/additional/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final List<ChatBubble> _chatBubbles = [
  //   ChatBubble(
  //       chatModel: ChatModel(
  //           "Hi!\nI'm Smart Care AI Agent.\nWhat is your problem?",
  //           "2024-01-01 11:01:14",
  //           false,
  //           "AI",
  //           "0")),
  // ];
  // bool _isLoading = true; // Loading state
  Account user = Account.instance;
  // final CredentialController credentialController = CredentialController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatModel> _chatMessages = [];
  final languages = ["English", "Sinhala", "Tamil"];
  String _selectedLanguage = "English";

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _sendMessage() {
  //   final message = _messageController.text.trim();
  //   if (message.isEmpty) return;

  //   _messageController.clear();
  //   Future.delayed(const Duration(milliseconds: 100), () {
  //     if (_scrollController.hasClients) {
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeOut,
  //       );
  //     }
  //   });
  //   onSend();
  // }

  @override
  void initState() {
    super.initState();
    Account().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    Map<String, dynamic> res = await FirestoreDbService().fetchChats(user.uid);
    if (res['success']) {
      setState(() {
        _chatMessages = List<ChatModel>.from(res['data']);
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
      _selectedLanguage = user.language;
    });
    // setState(() {
    //   _isLoading = false;
    // });
  }

  void sendToAI(ChatModel chatModel, String msg) async {
    String d =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";

    // Define the URL with the IP and port
    const String url =
        'http://10.10.30.65:8000/chat'; // Replace `your-endpoint` with the actual API endpoint

    // Define the payload (data to send in the POST request)
    final Map<String, String> payload = {
      'message': msg,
      'language': _selectedLanguage,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the AI's response from the JSON
        final String aiMessage = responseData['response'];

        // Create a new ChatModel object for the AI's response
        final aiResponse = ChatModel(aiMessage, d, false, "AI", "0");

        Map<String, dynamic> res =
            await FirestoreDbService().sendChats(user.uid, aiResponse);

        if (res['success']) {
          aiResponse.chatId = res['key'];
          setState(() {
            _chatMessages.add(aiResponse);
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
      } else {
        print('Request failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void onSend() async {
    String msg = _messageController.text;
    String d =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    final chatModel = ChatModel(msg, d, true, "Me", "0");

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    Map<String, dynamic> res =
        await FirestoreDbService().sendChats(user.uid, chatModel);
    if (res['success']) {
      chatModel.chatId = res['key'];
      setState(() {
        _chatMessages.add(chatModel);
      });
      sendToAI(chatModel, msg);
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
        await FirestoreDbService().deleteChats(user.uid, _chatMessages);
    if (res['success']) {
      setState(() {
        _chatMessages.clear();
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

// @override
// void dispose() {
//   _messageController.dispose();
//   _scrollController.dispose();
//   super.dispose();
// }

// void _sendMessage() {
//   final message = _messageController.text.trim();
//   if (message.isEmpty) return;

//   // Provider.of<PatientProvider>(context, listen: false)
//       .sendChatMessage(message);
//   _messageController.clear();

//   // Scroll to bottom after message is sent
//   Future.delayed(const Duration(milliseconds: 100), () {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   });
// }

// @override
// void initState() {
//   super.initState();

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _initializeData();
//   });
// }

// void _initializeData() async {
//   Map<String, dynamic> res =
//       await FirestoreDbService().fetchChats(widget.user!.uid);
//   if (res['success']) {
//     setState(() {
//       final tempChatBubbles = res['data'] as List<ChatModel>;
//       for (var element in tempChatBubbles) {
//         _chatBubbles.add(ChatBubble(chatModel: element));
//       }
//     });
//   } else {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res['error']),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }
//   setState(() {
//     _isLoading = false;
//   });
// }

// void sendToAI(ChatModel chatModel) async {
//   /*

//   AI API call

//   */
//   String d =
//       "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
//   final aiResponse = ChatModel("I got your msg", d, false, "AI", "0");

//   Map<String, dynamic> res =
//       await FirestoreDbService().sendChats(widget.user!.uid, aiResponse);

//   if (res['success']) {
//     aiResponse.chatId = res['key'];
//     setState(() {
//       _chatBubbles.add(ChatBubble(chatModel: aiResponse));
//     });
//   } else {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res['error']),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }
// }

// void onSend() async {
//   String d =
//       "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";

//   final chatModel = ChatModel(credentialController.text, d, true, "Me", "0");

//   Map<String, dynamic> res =
//       await FirestoreDbService().sendChats(widget.user!.uid, chatModel);
//   if (res['success']) {
//     chatModel.chatId = res['key'];
//     setState(() {
//       _chatBubbles.add(ChatBubble(chatModel: chatModel));
//     });

//     sendToAI(chatModel);
//   } else {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res['error']),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }
// }

// void onClear() async {
//   Map<String, dynamic> res =
//       await FirestoreDbService().deleteChats(widget.user!.uid, _chatBubbles);
//   if (res['success']) {
//     setState(() {
//       _chatBubbles.clear();
//     });
//   } else {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(res['error']),
//           backgroundColor: Colors.red,
//         ),
//       );
//     });
//   }
// }

  @override
  Widget build(BuildContext context) {
    // Scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.teal,
                radius: 20,
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SmartCare',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI Health Assistant',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) async {
                  setState(() {
                    _selectedLanguage = newValue!;
                    user.language = newValue;
                  });
                  await FirestoreDbService()
                      .updateLanguage(user.uid, newValue!);

                  // Handle language change here
                },
                items: languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Chat'),
                      content: const Text(
                          'Are you sure you want to clear all messages?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onClear();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _chatMessages.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: onSend,
                mini: true,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.smart_toy,
            size: 80,
            color: Colors.teal,
          ),
          const SizedBox(height: 16),
          const Text(
            'SmartCare AI Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ask me anything about your heart health, reports, or medical information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // ElevatedButton(
          //   onPressed: () {
          //     onSend();
          //   },
          //   child: const Text('Start Conversation'),
          // ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message) {
    final isUser = message.isSender;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 16,
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.msg,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isUser ? Colors.white.withOpacity(0.7) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Center(
//           child: CircularProgressIndicator(
//         backgroundColor: Colors.white,
//         color: StyleSheet().btnBackground,
//       ));
//     }
//     return Container(
//       color: StyleSheet().uiBackground,
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _chatBubbles.length,
//               itemBuilder: (context, index) {
//                 return _chatBubbles[index];
//               },
//             ),
//           ),
//           Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextInputWithSend(
//                 inputController: credentialController,
//                 hint: "Message",
//                 hintColor: StyleSheet().greyHint,
//                 textColor: StyleSheet().text,
//                 iconColor: StyleSheet().chatIcon,
//                 fontSize: AppSizes().getBlockSizeHorizontal(5),
//                 shadowColor: StyleSheet().textBackground,
//                 enableBorderColor: StyleSheet().disabledBorder,
//                 focusedBorderColor: StyleSheet().enableBorder,
//                 icon: Icons.message,
//                 typeKey: CustomTextInputTypes().text,
//                 onSend: onSend,
//                 onClear: onClear,
//               )),
//         ],
//       ),
//     );
//   }
// }
