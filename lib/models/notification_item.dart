class NotificationItem {
  final String id;
  final String sentimentLabel;
  final String previewText;
  final DateTime createdAt;
  final bool needsApproval;
  final String commentId;
  final String aiReply;

  const NotificationItem({
    required this.id,
    required this.sentimentLabel,
    required this.previewText,
    required this.createdAt,
    required this.needsApproval,
    required this.commentId,
    required this.aiReply,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'].toString(),
        sentimentLabel: json['sentiment_label'] as String? ?? 'neutral',
        previewText: json['text'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        needsApproval: json['needs_approval'] as bool? ?? false,
        commentId: json['comment_id'].toString(),
        aiReply: json['ai_reply'] as String? ?? '',
      );
}


