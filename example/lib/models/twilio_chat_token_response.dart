class TwilioChatTokenResponse {
  final String? identity;
  final String? token;

  TwilioChatTokenResponse({
    required this.identity,
    required this.token,
  });

  factory TwilioChatTokenResponse.fromMap(Map<String, dynamic> data) {
    return TwilioChatTokenResponse(
      identity: data['identity'],
      token: data['token'],
    );
  }
}
