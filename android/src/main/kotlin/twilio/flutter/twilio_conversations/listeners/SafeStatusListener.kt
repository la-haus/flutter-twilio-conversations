package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.StatusListener
import com.twilio.util.ErrorInfo

interface SafeStatusListener : StatusListener {
    override fun onSuccess() {
        try {
            onSafeSuccess()
        } catch (e: Exception) {
            val errorInfo = ErrorInfo(-1, e.message ?: "Unknown error")
            onError(errorInfo)
        }
    }

    fun onSafeSuccess()
}