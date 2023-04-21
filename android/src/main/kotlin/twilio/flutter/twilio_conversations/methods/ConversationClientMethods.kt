package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.util.ErrorInfo
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
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeNullableCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeStatusListener

class ConversationClientMethods : Api.ConversationClientApi {
    private val TAG = "ConversationClientMethods"

    override fun updateToken(token: String, result: Api.Result<Void>) {
        debug("updateToken")

        try {
            TwilioConversationsPlugin.client?.updateToken(token, object : SafeStatusListener {
                override fun onSafeSuccess() {
                    debug("updateToken => onSuccess")
                    result.success(null)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("updateToken => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("updateToken => onError: $err")
            return result.error(err)
        }
    }

    override fun shutdown() {
        debug("shutdown")

        try {
            TwilioConversationsPlugin.client?.shutdown()
        } catch (err: Exception) {
            debug("shutdown => shutdown.onError: $err")
        }

        try {
            disposeListeners()
        } catch (err: Exception) {
            debug("shutdown => disposeListeners.onError: $err")
        }
    }

    override fun createConversation(
        friendlyName: String,
        result: Api.Result<Api.ConversationData?>
    ) {
        debug("createConversation")
        try {
            TwilioConversationsPlugin.client?.createConversation(friendlyName, object :
                SafeNullableCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation?) {
                    if (item == null) {
                        debug("createConversation => onError: Conversation null")
                        result.error(RuntimeException("Error creating conversation: Conversation null"))
                        return
                    }
                    debug("createConversation => onSuccess")
                    val conversationMap = Mapper.conversationToPigeon(item)
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
            try {
                val myConversations = TwilioConversationsPlugin.client?.myConversations
                var conversationsSynchronized = false

                while (!conversationsSynchronized) {
                    conversationsSynchronized = true

                    val convoStatuses = myConversations?.map { it.synchronizationStatus }
                    convoStatuses?.forEach {
                        conversationsSynchronized =
                            (conversationsSynchronized && (it == Conversation.SynchronizationStatus.ALL))
                    }

                    delay(100)
                }

                launch(Dispatchers.Main) {
                    debug("getMyConversations => onSuccess")
                    val conversationsList = Mapper.conversationsListToPigeon(myConversations)
                    result.success(conversationsList.toMutableList())
                }
            } catch (err: Exception) {
                launch(Dispatchers.Main) {
                    debug("getMyConversations => onError: $err")
                    result.error(err)
                }
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

        try {
            client.getConversation(
                conversationSidOrUniqueName,
                object : SafeNullableCallbackListener<Conversation> {
                    override fun onSafeSuccess(item: Conversation?) {
                        debug("getConversations => callback.onSuccess")
                        result.success(Mapper.conversationToPigeon(item))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getConversations => callback.onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
        } catch (err: Exception) {
            debug("getConversations => onError: $err")
            return result.error(err)
        }
    }

    override fun getMyUser(result: Api.Result<Api.UserData>) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        return try {
            val myUser = client.myUser
            result.success(Mapper.userToPigeon(myUser))
        } catch (err: Exception) {
            result.error(err)
        }
    }

    override fun registerForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(MissingParameterException("The parameter 'token' was not provided"))

        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.registerFCMToken(
                ConversationsClient.FCMToken(token),
                object : SafeStatusListener {
                    override fun onSafeSuccess() {
                        TwilioConversationsPlugin.flutterClientApi.registered { }
                        result.success(null)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        super.onError(errorInfo)
                        TwilioConversationsPlugin.flutterClientApi.registrationFailed(
                            Mapper.errorInfoToPigeon(
                                errorInfo
                            )
                        ) { }
                        result.error(
                            TwilioException(
                                errorInfo.code,
                                "Failed to register for FCM notifications: ${errorInfo.message}"
                            )
                        )
                    }
                })
        } catch (err: Exception) {
            debug("registerForNotification => onError: $err")
            result.error(err)
        }
    }

    override fun unregisterForNotification(tokenData: Api.TokenData, result: Api.Result<Void>) {
        val token: String = tokenData.token
            ?: return result.error(MissingParameterException("The parameter 'token' was not provided"))

        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.unregisterFCMToken(
                ConversationsClient.FCMToken(token),
                object : SafeStatusListener {
                    override fun onSafeSuccess() {
                        TwilioConversationsPlugin.flutterClientApi.deregistered { }
                        result.success(null)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        super.onError(errorInfo)
                        TwilioConversationsPlugin.flutterClientApi.deregistrationFailed(
                            Mapper.errorInfoToPigeon(
                                errorInfo
                            )
                        ) { }
                        result.error(
                            TwilioException(
                                errorInfo.code,
                                "Failed to register for FCM notifications: ${errorInfo.message}"
                            )
                        )
                    }
                })
        } catch (err: Exception) {
            debug("unregisterForNotification => onError: $err")
            result.error(err)
        }
    }

    private fun disposeListeners() {
        try {
            TwilioConversationsPlugin.conversationListeners.clear()
        } catch (err: Exception) {
            debug("disposeListeners => onError: $err")
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
