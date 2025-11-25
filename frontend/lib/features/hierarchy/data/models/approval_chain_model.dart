class ApprovalChainEntry {
  final int level;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final String? reason;

  ApprovalChainEntry({
    required this.level,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    this.reason,
  });

  factory ApprovalChainEntry.fromJson(Map<String, dynamic> json) {
    return ApprovalChainEntry(
      level: json['level'] as int,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'userId': userId,
      'userName': userName,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      if (reason != null) 'reason': reason,
    };
  }

  bool get isApproved => action == 'approved';
  bool get isRejected => action == 'rejected';
}
