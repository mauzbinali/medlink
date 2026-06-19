enum ChatSender { patient, doctor, clinic }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.appointmentId,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String appointmentId;
  final ChatSender sender;
  final String message;
  final DateTime createdAt;
}
