class CommentSummary {
  final String id;
  final String text;
  final String aiReply;
  final String sentimentLabel;

  const CommentSummary({
    required this.id,
    required this.text,
    required this.aiReply,
    required this.sentimentLabel,
  });

  factory CommentSummary.fromJson(Map<String, dynamic> json) => CommentSummary(
        id: json['id'].toString(),
        text: json['text'] as String? ?? '',
        aiReply: json['ai_reply'] as String? ?? '',
        sentimentLabel: json['sentiment_label'] as String? ?? 'neutral',
      );
}


