package twilio.flutter.twilio_conversations.methods

import com.google.gson.Gson
import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ErrorInfo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

object ParticipantMethods {
    fun getUser(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)
        val participantSid = call.argument<String>("participantSid")
                ?: return result.error("ERROR", "Missing 'participantSid'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                val participant = conversation.participantsList.firstOrNull {
                    it.sid == participantSid
                }

                participant?.getAndSubscribeUser {
                    result.success(Gson().toJson(Mapper.userToMap(it)))
                } ?: result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}