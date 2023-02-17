package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.util.ErrorInfo
import com.twilio.conversations.Message
import com.twilio.conversations.StatusListener
import com.twilio.conversations.extensions.getTemporaryContentUrlsForMedia
import com.twilio.conversations.extensions.updateMessageBody
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.ClientNotInitializedException
import twilio.flutter.twilio_conversations.exceptions.ConversionException
import twilio.flutter.twilio_conversations.exceptions.NotFoundException
import twilio.flutter.twilio_conversations.exceptions.TwilioException

class MessageMethods : Api.MessageApi {
    private val TAG = "MessageMethods"

    override fun getMediaContentTemporaryUrl(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<String>
    ) {
        debug("getMediaContentTemporaryUrl => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        if (message.attachedMedia.isEmpty()) {
                            val error =
                                NotFoundException("No media attached to message: $messageIndex.")
                            return result.error(error)
                        }

                        GlobalScope.launch {
                            val urls = message.getTemporaryContentUrlsForMedia(message.attachedMedia)
                            val url = urls[urls.keys.first()]
                            result.success(url)
                        }
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getMediaContentTemporaryUrl => onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getMediaContentTemporaryUrl => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    override fun getParticipant(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<Api.ParticipantData>
    ) {
        debug("getParticipant => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        val participant = message.participant
                            ?: return result.error(NotFoundException("Participant not found for message: $messageIndex."))
                        debug("getParticipant => onSuccess")
                        return result.success(Mapper.participantToPigeon(participant))
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getParticipant => onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getParticipant => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    override fun setAttributes(
        conversationSid: String,
        messageIndex: Long,
        attributes: Api.AttributesData,
        result: Api.Result<Void>
    ) {
        debug("setAttributes => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))
        val messageAttributes = Mapper.pigeonToAttributes(attributes)
            ?: return result.error(ConversionException("Could not convert $attributes to valid Attributes"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        message.setAttributes(messageAttributes, object : StatusListener {
                            override fun onSuccess() {
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
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("setAttributes => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    override fun updateMessageBody(
        conversationSid: String,
        messageIndex: Long,
        messageBody: String,
        result: Api.Result<Void>
    ) {
        debug("updateMessageBody => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        // TODO: Handle error case
                        GlobalScope.launch { message.updateMessageBody(messageBody) }
                        result.success(null)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("updateMessageBody => onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("updateMessageBody => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }

    override fun getAggregatedDeliveryReceipt(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<Api.DeliveryReceiptData>
    ) {
        debug("getAggregatedDeliveryReceipt => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        client.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessageByIndex(messageIndex, object : CallbackListener<Message> {
                    override fun onSuccess(message: Message) {
                        val aggregatedDeliveryReceipt =
                            message.aggregatedDeliveryReceipt ?: return result.error(
                                NotFoundException("AggregatedDeliveryReceipt not found for message: $messageIndex.")
                            )
                        debug("getAggregatedDeliveryReceipt => onSuccess")
                        return result.success(
                            Mapper.aggregatedDeliveryReceiptToPigeon(
                                aggregatedDeliveryReceipt
                            )
                        )
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getAggregatedDeliveryReceipt => onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                debug("getMediaContentTemporaryUrl => onError: $errorInfo")
                result.error(TwilioException(errorInfo.code, errorInfo.message))
            }
        })
    }
}
