class TwilioChatTokenRequest {
  final String? identity;

  TwilioChatTokenRequest({
    required this.identity,
  });

  factory TwilioChatTokenRequest.fromMap(Map<String, dynamic> data) {
    return TwilioChatTokenRequest(
      identity: data['identity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identity': identity,
    };
  }
}
