// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smartcare/providers/patient_provider.dart';
// import 'package:smartcare/models/chat_message.dart';
// import 'package:intl/intl.dart';

// class ChatTab extends StatefulWidget {
//   const ChatTab({super.key});

//   @override
//   State<ChatTab> createState() => _ChatTabState();
// }

// class _ChatTabState extends State<ChatTab> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isEmpty) return;

//     Provider.of<PatientProvider>(context, listen: false)
//         .sendChatMessage(message);
//     _messageController.clear();

//     // Scroll to bottom after message is sent
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final patientProvider = Provider.of<PatientProvider>(context);
//     final messages = patientProvider.chatMessages;

//     // Scroll to bottom when new messages are added
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 backgroundColor: Colors.teal,
//                 radius: 20,
//                 child: Icon(
//                   Icons.smart_toy,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SmartCare',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'AI Health Assistant',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.delete_outline),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Clear Chat'),
//                       content: const Text(
//                           'Are you sure you want to clear all messages?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             patientProvider.clearChat();
//                             Navigator.pop(context);
//                           },
//                           child: const Text('Clear'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1),
//         Expanded(
//           child: messages.isEmpty
//               ? _buildEmptyChat()
//               : ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     return _buildMessageBubble(message);
//                   },
//                 ),
//         ),
//         const Divider(height: 1),
//         Padding(
//           padding: const EdgeInsets.all(8),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _messageController,
//                   decoration: InputDecoration(
//                     hintText: 'Type a message...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(24),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                   ),
//                   textInputAction: TextInputAction.send,
//                   onSubmitted: (_) => _sendMessage(),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               FloatingActionButton(
//                 onPressed: _sendMessage,
//                 mini: true,
//                 child: const Icon(Icons.send),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyChat() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.smart_toy,
//             size: 80,
//             color: Colors.teal,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'SmartCare AI Assistant',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               'Ask me anything about your heart health, reports, or medical information.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               Provider.of<PatientProvider>(context, listen: false)
//                   .sendChatMessage('Hello');
//             },
//             child: const Text('Start Conversation'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     final isUser = message.type == MessageType.user;
//     final timeFormat = DateFormat('HH:mm');

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser) ...[
//             const CircleAvatar(
//               backgroundColor: Colors.teal,
//               radius: 16,
//               child: Icon(
//                 Icons.smart_toy,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 10,
//               ),
//               decoration: BoxDecoration(
//                 color: isUser ? Colors.teal : Colors.grey[200],
//                 borderRadius: BorderRadius.circular(16).copyWith(
//                   bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
//                   bottomRight: isUser ? Radius.zero : const Radius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message.message,
//                     style: TextStyle(
//                       color: isUser ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     timeFormat.format(message.timestamp),
//                     style: TextStyle(
//                       fontSize: 10,
//                       color:
//                           isUser ? Colors.white.withOpacity(0.7) : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isUser) const SizedBox(width: 8),
//         ],
//       ),
//     );
//   }
// }
