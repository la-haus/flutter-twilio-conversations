package twilio.flutter.twilio_conversations

import ConversationMethods
import android.content.Context
import com.google.gson.Gson
import com.twilio.conversations.CallbackListener
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ErrorInfo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.methods.*

class PluginMethodCallHandler(private val applicationContext: Context) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "debug" -> debug(call, result)
            "create" -> create(call, result)
            "registerForNotification" -> TwilioConversationsPlugin.instance.registerForNotification(call, result)
            "unregisterForNotification" -> TwilioConversationsPlugin.instance.unregisterForNotification(call, result)

            "ConversationClientMethods.updateToken" -> ConversationClientMethods.updateToken(call, result)
            "ConversationClientMethods.shutdown" -> ConversationClientMethods.shutdown(call, result)

            "ConversationMethods.join" -> ConversationMethods.join(call, result)
            "ConversationMethods.leave" -> ConversationMethods.leave(call, result)
            "ConversationMethods.typing" -> ConversationMethods.typing(call, result)
            "ConversationMethods.setFriendlyName" -> ConversationMethods.setFriendlyName(call, result)
            "ConversationMethods.getUnreadMessagesCount" -> ConversationMethods.getUnreadMessagesCount(call, result)

            "ConversationsMethods.getConversation" -> ConversationsMethods.getConversation(call, result)
            "ConversationsMethods.createConversation" -> ConversationsMethods.createConversation(call, result)
            "ConversationsMethods.getMyConversations" -> ConversationsMethods.getMyConversations(call, result)

            "MessageMethods.getMediaContentTemporaryUrl" -> MessageMethods.getMediaContentTemporaryUrl(call, result)

            "MessagesMethods.sendMessage" -> MessagesMethods.sendMessage(call, result)
            "MessagesMethods.getLastMessages" -> MessagesMethods.getLastMessages(call, result)
            "MessagesMethods.getMessagesBefore" -> MessagesMethods.getMessagesBefore(call, result)
            "MessagesMethods.setAllMessagesRead" -> MessagesMethods.setAllMessagesRead(call, result)
            "MessagesMethods.setLastReadMessageIndex" -> MessagesMethods.setLastReadMessageIndex(call, result)

            "ParticipantMethods.getUser" -> ParticipantMethods.getUser(call, result)

            "ParticipantsMethods.getUsers" -> ParticipantsMethods.getUsers(call, result)
            "ParticipantsMethods.getParticipantsList" -> ParticipantsMethods.getParticipantsList(call, result)
            "ParticipantsMethods.addParticipantByIdentity" -> ParticipantsMethods.addParticipantByIdentity(call, result)
            "ParticipantsMethods.removeParticipantByIdentity" -> ParticipantsMethods.removeParticipantByIdentity(call, result)

            else -> result.notImplemented()
        }
    }

    private fun create(call: MethodCall, result: MethodChannel.Result) {
        val jwtToken = call.argument<String>("jwtToken")
                ?: return result.error("ERROR", "Missing token", null)
        val props = ConversationsClient.Properties.newBuilder().createProperties()

        ConversationsClient.create(applicationContext, jwtToken, props, object : CallbackListener<ConversationsClient> {
            override fun onSuccess(conversationsClient: ConversationsClient) {
                TwilioConversationsPlugin.client = conversationsClient
                conversationsClient.addListener(TwilioConversationsPlugin.clientListener)
                val jsonMap = Gson().toJson(Mapper.conversationsClientToMap(conversationsClient))
                result.success(jsonMap)
            }

            override fun onError(errorInfo: ErrorInfo) {
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    private fun debug(call: MethodCall, result: MethodChannel.Result) {
        val enableNative = call.argument<Boolean>("native")
        val enableSdk = call.argument<Boolean>("sdk")

        if (enableSdk != null && enableSdk) {
            ConversationsClient.setLogLevel(ConversationsClient.LogLevel.DEBUG)
        }

        if (enableNative != null) {
            TwilioConversationsPlugin.nativeDebug = enableNative
            result.success(enableNative)
        } else {
            result.error("MISSING_PARAMS", "Missing 'native' parameter", null)
        }
    }
}