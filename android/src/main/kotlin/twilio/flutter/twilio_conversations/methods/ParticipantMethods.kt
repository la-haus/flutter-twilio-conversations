package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.Conversation
import com.twilio.util.ErrorInfo
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.ClientNotInitializedException
import twilio.flutter.twilio_conversations.exceptions.ConversionException
import twilio.flutter.twilio_conversations.exceptions.NotFoundException
import twilio.flutter.twilio_conversations.exceptions.TwilioException
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeStatusListener

class ParticipantMethods : Api.ParticipantApi {
    private val TAG = "ParticipantMethods"

    override fun getUser(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Api.UserData>
    ) {
        debug("getUser => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantBySid(participantSid)
                        ?: return result.error(NotFoundException("No participant found with SID: $participantSid"))

                    participant.getAndSubscribeUser {
                        debug("getUser => onSuccess")
                        result.success(Mapper.userToPigeon(it))
                    }
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getUser => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (e: Exception) {
            debug("getUser => onError: $e")
            result.error(TwilioException(-1, e.message ?: "Unknown error"))
        }
    }

    override fun setAttributes(
        conversationSid: String,
        participantSid: String,
        attributes: Api.AttributesData,
        result: Api.Result<Void>
    ) {
        debug("setAttributes => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))
        val participantAttributes = Mapper.pigeonToAttributes(attributes)
            ?: return result.error(ConversionException("Could not convert $attributes to valid Attributes"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantBySid(participantSid)
                        ?: return result.error(NotFoundException("No participant found with SID: $participantSid"))
                    participant.setAttributes(participantAttributes, object : SafeStatusListener {
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
        } catch (e: Exception) {
            debug("setAttributes => onError: $e")
            result.error(TwilioException(-1, e.message ?: "Unknown error"))
        }
    }

    override fun remove(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Void>
    ) {
        debug("remove => conversationSid: $conversationSid, participantSid: $participantSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantBySid(participantSid)
                        ?: return result.error(NotFoundException("No participant found with SID: $participantSid"))
                    participant.remove(object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("remove => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("remove => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("remove => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (e: Exception) {
            debug("remove => onError: $e")
            result.error(TwilioException(-1, e.message ?: "Unknown error"))
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
