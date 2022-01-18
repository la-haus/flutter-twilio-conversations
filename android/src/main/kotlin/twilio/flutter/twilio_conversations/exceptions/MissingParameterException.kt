package twilio.flutter.twilio_conversations.exceptions

class MissingParameterException(message: String) : RuntimeException(message) {
    override fun toString(): String {
        return message ?: "MissingParameterException"
    }
}
