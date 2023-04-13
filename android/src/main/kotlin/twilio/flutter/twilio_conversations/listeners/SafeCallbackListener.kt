package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.CallbackListener
import com.twilio.util.ErrorInfo

interface SafeCallbackListener<T> : CallbackListener<T> {
    override fun onSuccess(result: T) {
        try {
            onSafeSuccess(result)
        } catch (e: Exception) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        }
    }

    fun onSafeSuccess(item: T)
}