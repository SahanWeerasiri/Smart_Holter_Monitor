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

  // Convert ChatMessage to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'type': type == MessageType.user ? 'user' : 'bot', // Store as string
      'timestamp':
          timestamp.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }

  // Create ChatMessage from a Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      message: map['message'],
      type: map['type'] == 'user'
          ? MessageType.user
          : MessageType.bot, // Convert string to enum
      timestamp: DateTime.parse(
          map['timestamp']), // Convert ISO 8601 string to DateTime
    );
  }
}
