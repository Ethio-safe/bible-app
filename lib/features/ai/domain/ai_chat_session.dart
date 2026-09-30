class AiChatMessageData {
  const AiChatMessageData({required this.text, required this.isUser});

  factory AiChatMessageData.fromJson(Map<String, dynamic> json) =>
      AiChatMessageData(
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
      );

  final String text;
  final bool isUser;

  Map<String, dynamic> toJson() => {'text': text, 'isUser': isUser};
}

/// A single saved conversation with the Bible AI assistant.
class AiChatSession {
  const AiChatSession({
    required this.id,
    required this.updatedAt,
    required this.messages,
  });

  factory AiChatSession.fromJson(Map<String, dynamic> json) => AiChatSession(
    id: json['id'] as String,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    messages: (json['messages'] as List<dynamic>)
        .map((e) => AiChatMessageData.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final String id;
  final DateTime updatedAt;
  final List<AiChatMessageData> messages;

  /// A short label derived from the first user question, used in the history list.
  String get title {
    final first = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.isEmpty
          ? const AiChatMessageData(text: 'New chat', isUser: true)
          : messages.first,
    );
    final oneLine = first.text.replaceAll('\n', ' ').trim();
    return oneLine.length > 60 ? '${oneLine.substring(0, 60)}…' : oneLine;
  }

  /// A short preview of the latest message, used as a subtitle.
  String get preview {
    if (messages.isEmpty) return '';
    final last = messages.last.text.replaceAll('\n', ' ').trim();
    return last.length > 80 ? '${last.substring(0, 80)}…' : last;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'messages': messages.map((m) => m.toJson()).toList(growable: false),
  };

  AiChatSession copyWith({
    List<AiChatMessageData>? messages,
    DateTime? updatedAt,
  }) => AiChatSession(
    id: id,
    updatedAt: updatedAt ?? this.updatedAt,
    messages: messages ?? this.messages,
  );
}
