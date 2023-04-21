package twilio.flutter.twilio_conversations.listeners

import com.twilio.conversations.CallbackListener
import com.twilio.util.ErrorInfo
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

interface SafeNullableCallbackListener<T> : CallbackListener<T?> {
    override fun onSuccess(result: T?) {
        try {
            onSafeSuccess(result)
        } catch (e: Exception) {
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
        }
    }

    fun onSafeSuccess(item: T)
}

interface SafeSuspendCallbackListener<T> : CallbackListener<T> {
    override fun onSuccess(result: T) {
        try {
            if (result != null) {
                GlobalScope.launch {
                    try {
                        onSafeSuccess(result)
                    } catch (e: Exception) {
                        onError(ErrorInfo(-1, e.message ?: "Unknown error"))
                    }
                }
            } else {
                onError(ErrorInfo(-1, "Got a null result"))
            }
        } catch (e: Exception) {
            onError(ErrorInfo(-1, e.message ?: "Unknown error"))
        }
    }

    suspend fun onSafeSuccess(item: T)
}