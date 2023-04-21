package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.ConversationsClient
import com.twilio.util.ErrorInfo
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.TwilioException
import twilio.flutter.twilio_conversations.listeners.ClientListener
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener

class PluginMethods : Api.PluginApi {
    private val TAG = "PluginMethods"

    override fun debug(enableNative: Boolean, enableSdk: Boolean) {
        if (enableSdk) {
            ConversationsClient.setLogLevel(ConversationsClient.LogLevel.DEBUG)
        } else {
            ConversationsClient.setLogLevel(ConversationsClient.LogLevel.ERROR)
        }

        TwilioConversationsPlugin.nativeDebug = enableNative
        return
    }

    override fun create(jwtToken: String, properties: Api.PropertiesData, result: Api.Result<Api.ConversationClientData>) {
        debug("create => jwtToken: $jwtToken")

        try {
            val props = ConversationsClient.Properties.newBuilder()
                .setRegion(properties.region)
                .createProperties()

            ConversationsClient.create(
                TwilioConversationsPlugin.applicationContext,
                jwtToken,
                props,
                object :
                    SafeCallbackListener<ConversationsClient> {
                    override fun onSafeSuccess(item: ConversationsClient) {
                        debug("create => onSuccess - myIdentity: '${item.myUser?.identity ?: "unknown"}'")
                        TwilioConversationsPlugin.client = item
                        TwilioConversationsPlugin.clientListener = ClientListener()
                        item.addListener(TwilioConversationsPlugin.clientListener!!)
                        val clientMap = Mapper.conversationsClientToPigeon(item)
                        result.success(clientMap)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("create => onError: ${errorInfo.message}")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
        } catch (e: Exception) {
            debug("create => onError: ${e.message}")
            result.error(TwilioException(-1, e.message ?: "Unknown error"))
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
