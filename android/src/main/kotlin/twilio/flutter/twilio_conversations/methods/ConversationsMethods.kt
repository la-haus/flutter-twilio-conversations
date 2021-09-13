package twilio.flutter.twilio_conversations.methods

import com.google.gson.Gson
import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ErrorInfo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

object ConversationsMethods {
    private const val TAG = "ConversationsMethods"

    fun getConversation(call: MethodCall, result: MethodChannel.Result) {
        val conversationSidOrUniqueName = call.argument<String>("conversationSidOrUniqueName")
                ?: return result.error("ERROR", "Missing 'conversationSidOrUniqueName'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSidOrUniqueName, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                result.success(Gson().toJson(Mapper.conversationToMap(conversation)))
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun createConversation(call: MethodCall, result: MethodChannel.Result) {
        val friendlyName = call.argument<String>("friendlyName")
                ?: return result.error("ERROR", "Missing 'friendlyName'", null)

        try {
            TwilioConversationsPlugin.client?.createConversation(friendlyName, object : CallbackListener<Conversation?> {
                override fun onSuccess(conversation: Conversation?) {
                    if (conversation == null) {
                        TwilioConversationsPlugin.debug("${call.method} => onError: Conversation null")
                        result.error(call.method, "Error creating conversation: Conversation null", null)
                        return
                    }
                    TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                    val jsonMap = Gson().toJson(Mapper.conversationToMap(conversation))
                    result.success(jsonMap)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getMyConversations(call: MethodCall, result: MethodChannel.Result) {
        GlobalScope.launch {
            val myConversations = TwilioConversationsPlugin.client?.myConversations
            var conversationsSynchronized = false

            while (!conversationsSynchronized) {
                conversationsSynchronized = true

                val convoStatuses = myConversations?.map { it.synchronizationStatus }
                convoStatuses?.forEach {
                    conversationsSynchronized = (conversationsSynchronized && (it == Conversation.SynchronizationStatus.ALL))
                }

                delay(100)
            }

            launch(Dispatchers.Main) {
                TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                val jsonMap = Gson().toJson(Mapper.conversationsToMap(myConversations))
                result.success(jsonMap)
            }
        }
    }
}