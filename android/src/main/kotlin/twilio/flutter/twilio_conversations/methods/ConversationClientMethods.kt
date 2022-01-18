package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.StatusListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.ClientNotInitializedException
import twilio.flutter.twilio_conversations.exceptions.MissingParameterException
import twilio.flutter.twilio_conversations.exceptions.TwilioException

class ConversationClientMethods : Api.ConversationClientApi {
    private val TAG = "ConversationClientMethods"

    override fun updateToken(token: String, result: Api.Result<Void>) {
        debug("updateToken")
        TwilioConversationsPlugin.client?.updateToken(token, object : StatusListener {
            override fun onSuccess() {
                debug("updateToken => onSuccess")
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("updateToken => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    override fun shutdown() {
        debug("shutdown")
        TwilioConversationsPlugin.client?.shutdown()
        disposeListeners()
    }

    override fun createConversation(
        friendlyName: String,
        result: Api.Result<Api.ConversationData?>
    ) {
        debug("createConversation")
        try {
            TwilioConversationsPlugin.client?.createConversation(friendlyName, object :
                CallbackListener<Conversation?> {
                override fun onSuccess(conversation: Conversation?) {
                    if (conversation == null) {
                        debug("createConversation => onError: Conversation null")
                        result.error(RuntimeException("Error creating conversation: Conversation null"))
                        return
                    }
                    debug("createConversation => onSuccess")
                    val conversationMap = Mapper.conversationToPigeon(conversation)
                    result.success(conversationMap)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("createConversation => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error(IllegalArgumentException(err.message))
        }
    }

    override fun getMyConversations(result: Api.Result<MutableList<Api.ConversationData>>) {
        debug("getMyConversations")
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
                debug("getMyConversations => onSuccess")
                val conversationsList = Mapper.conversationsListToPigeon(myConversations)
                result.success(conversationsList.toMutableList())
            }
        }
    }

    override fun getConversation(
        conversationSidOrUniqueName: String,
        result: Api.Result<Api.ConversationData>
    ) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        debug("getConversations => conversationSidOrUniqueName: $conversationSidOrUniqueName")
        client.getConversation(conversationSidOrUniqueName, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                debug("getConversations => onSuccess")
                result.success(Mapper.conversationToPigeon(conversation))
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getConversations => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    override fun getMyUser(result: Api.Result<Api.UserData>) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        val myUser = client.myUser
        return result.success(Mapper.userToPigeon(myUser))
    }

    override fun registerForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(MissingParameterException("The parameter 'token' was not provided"))

        TwilioConversationsPlugin.client?.registerFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                TwilioConversationsPlugin.flutterClientApi.registered { }
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                super.onError(errorInfo)
                TwilioConversationsPlugin.flutterClientApi.registrationFailed(Mapper.errorInfoToPigeon(errorInfo)) { }
                result.error(TwilioException(errorInfo.code, "Failed to register for FCM notifications: ${errorInfo.message}"))
            }
        })
    }

    override fun unregisterForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(MissingParameterException("The parameter 'token' was not provided"))

        TwilioConversationsPlugin.client?.unregisterFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                TwilioConversationsPlugin.flutterClientApi.deregistered { }
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                super.onError(errorInfo)
                TwilioConversationsPlugin.flutterClientApi.deregistrationFailed(Mapper.errorInfoToPigeon(errorInfo)) { }
                result.error(TwilioException(errorInfo.code, "Failed to register for FCM notifications: ${errorInfo.message}"))
            }
        })
    }

    private fun disposeListeners() {
        TwilioConversationsPlugin.conversationListeners.clear()
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
