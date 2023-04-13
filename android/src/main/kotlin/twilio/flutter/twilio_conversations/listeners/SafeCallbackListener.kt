package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.CallbackListener
import com.twilio.util.ErrorInfo

interface SafeNullableCallbackListener<T> : CallbackListener<T?> {
    override fun onSuccess(result: T?) {
        try {
            if (result != null) {
                onSafeSuccess(result)
            } else {
                onError(ErrorInfo(-1, "Got a null result"))
            }
        } catch (e: Exception) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        } catch (e: Throwable) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        } catch (e: NullPointerException) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        }
    }

    fun onSafeSuccess(item: T?)
}

interface SafeCallbackListener<T> : CallbackListener<T> {
    override fun onSuccess(result: T) {
        try {
            if (result != null) {
                onSafeSuccess(result)
            } else {
                onError(ErrorInfo(-1, "Got a null result"))
            }
        } catch (e: Exception) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        } catch (e: Throwable) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        } catch (e: NullPointerException) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        }
    }

    fun onSafeSuccess(item: T)
}