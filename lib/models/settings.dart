class InstagramSettings {
  bool autoCommentEnabled;
  bool? requireApprovalForNegative;
  bool? requireApprovalForHate;
  bool? notifyOnPositive;
  bool? notifyOnNegative;
  bool? notifyOnHate;
  bool? notifyOnNeutral;
  bool? notifyOnPurchaseIntent;
  bool? notifyOnQuestion;
  String responseStyle; // professional, casual, controversial, sarcastic

  InstagramSettings({
    required this.autoCommentEnabled,
    required this.responseStyle,
    this.requireApprovalForNegative,
    this.requireApprovalForHate,
    this.notifyOnPositive,
    this.notifyOnNegative,
    this.notifyOnHate,
    this.notifyOnNeutral,
    this.notifyOnPurchaseIntent,
    this.notifyOnQuestion,
  });

  factory InstagramSettings.fromJson(Map<String, dynamic> json) => InstagramSettings(
        autoCommentEnabled: json['auto_comment_enabled'] as bool? ?? false,
        responseStyle: json['response_style'] as String? ?? 'professional',
        requireApprovalForNegative: json['require_approval_for_negative'] as bool?,
        requireApprovalForHate: json['require_approval_for_hate'] as bool?,
        notifyOnPositive: json['notify_on_positive'] as bool?,
        notifyOnNegative: json['notify_on_negative'] as bool?,
        notifyOnHate: json['notify_on_hate'] as bool?,
        notifyOnNeutral: json['notify_on_neutral'] as bool?,
        notifyOnPurchaseIntent: json['notify_on_purchase_intent'] as bool?,
        notifyOnQuestion: json['notify_on_question'] as bool?,
      );

  Map<String, dynamic> toJson() {
    return {
      'auto_comment_enabled': autoCommentEnabled,
      'require_approval_for_negative': requireApprovalForNegative,
      'require_approval_for_hate': requireApprovalForHate,
      'notify_on_positive': notifyOnPositive,
      'notify_on_negative': notifyOnNegative,
      'notify_on_hate': notifyOnHate,
      'notify_on_neutral': notifyOnNeutral,
      'notify_on_purchase_intent': notifyOnPurchaseIntent,
      'notify_on_question': notifyOnQuestion,
      'response_style': responseStyle,
    }..removeWhere((key, value) => value == null);
  }
}


