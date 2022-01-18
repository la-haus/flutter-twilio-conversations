package twilio.flutter.twilio_conversations.exceptions

class ConversionException(message: String) : RuntimeException(message) {
    override fun toString(): String {
        return message ?: "ConversionException"
    }
}
