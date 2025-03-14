enum MessageType { user, bot }

class ChatMessage {
  final String id;
  final String message;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
  });
}