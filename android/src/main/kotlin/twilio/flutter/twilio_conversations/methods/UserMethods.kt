package twilio.flutter.twilio_conversations.methods

import com.twilio.util.ErrorInfo
import com.twilio.conversations.User
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.ClientNotInitializedException
import twilio.flutter.twilio_conversations.exceptions.ConversionException
import twilio.flutter.twilio_conversations.exceptions.TwilioException
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeStatusListener

class UserMethods : Api.UserApi {
    private val TAG = "UserMethods"

    override fun setFriendlyName(
        identity: String,
        friendlyName: String,
        result: Api.Result<Void>
    ) {
        debug("setFriendlyName => identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getAndSubscribeUser(identity, object : SafeCallbackListener<User> {
                override fun onSafeSuccess(item: User) {
                    item.setFriendlyName(friendlyName, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("setFriendlyName => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setFriendlyName => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setFriendlyName => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setFriendlyName => onError: $err")
            return result.error(err)
        }
    }

    override fun setAttributes(
        identity: String,
        attributes: Api.AttributesData,
        result: Api.Result<Void>
    ) {
        debug("setAttributes => identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))
        val userAttributes = Mapper.pigeonToAttributes(attributes)
            ?: return result.error(ConversionException("Could not convert $attributes to valid Attributes"))

        try {
            client.getAndSubscribeUser(identity, object : SafeCallbackListener<User> {
                override fun onSafeSuccess(item: User) {
                    item.setAttributes(userAttributes, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("setAttributes => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setAttributes => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setAttributes => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setAttributes => onError: $err")
            return result.error(err)
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
