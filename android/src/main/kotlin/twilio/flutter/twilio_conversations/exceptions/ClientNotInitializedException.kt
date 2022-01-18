package twilio.flutter.twilio_conversations.exceptions

class ClientNotInitializedException(message: String) : RuntimeException(message) {
    override fun toString(): String {
        return message ?: "ClientNotInitializedException"
    }
}
