package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import java.io.File

object MessageMethods {
    fun getMediaContentTemporaryUrl(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        val messageIndex = call.argument<Int>("messageIndex")?.toLong()
                ?: return result.error("ERROR", "Missing 'messageIndex'", null)
        
        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("MessageMethods.getMedia => onSuccess")
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        TwilioConversationsPlugin.debug("MessageMethods.getMedia (Messages.getMessageByIndex) => onSuccess")
                        message.getMediaContentTemporaryUrl(object : CallbackListener<String> {
                            override fun onSuccess(url: String) {
                                TwilioConversationsPlugin.debug("MessageMethods.getMedia (Message.Media.getMediaContentTemporaryUrl) => onSuccess $url")
                                result.success(url)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                TwilioConversationsPlugin.debug("MessageMethods.getMedia (Message.Media.getMediaContentTemporaryUrl) => onError: $errorInfo")
                                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                            }
                        })
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioConversationsPlugin.debug("MessageMethods.getMessageByIndex (Messages.getMessageByIndex) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("MessageMethods.getMedia => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}