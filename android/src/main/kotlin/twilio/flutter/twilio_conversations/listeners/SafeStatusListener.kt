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
        } catch (e: Throwable) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        } catch (e: NullPointerException) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        }
    }

    fun onSafeSuccess()
}