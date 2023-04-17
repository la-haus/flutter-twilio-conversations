package twilio.flutter.twilio_conversations.methods

import com.twilio.conversations.*
import com.twilio.conversations.extensions.getDetailedDeliveryReceiptList
import com.twilio.conversations.extensions.getMessageByIndex
import com.twilio.util.ErrorInfo
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
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeStatusListener

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

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        debug("getMediaContentTemporaryUrl => onSuccess: ${item.attachedMedia}")

                        if (item.attachedMedia.isEmpty()) {
                            return result.error(NotFoundException("No media attached to message"))
                        }

                        // TODO: Add support for multiple media
                        val media = item.attachedMedia.first()

                        media.getTemporaryContentUrl(
                            object : SafeCallbackListener<String> {
                                override fun onSafeSuccess(item: String) {
                                    debug("getMediaContentTemporaryUrl => onSuccess: $item")
                                    result.success(item)
                                }

                                override fun onError(errorInfo: ErrorInfo) {
                                    debug("getMediaContentTemporaryUrl => onError: $errorInfo")
                                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                                }
                            }
                        )
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

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        val participant = item.participant
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

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                val conversation = item

                conversation.getMessageByIndex(messageIndex, object :
                    SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        item.setAttributes(messageAttributes, object : SafeStatusListener {
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

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        // TODO: Handle error case
                        GlobalScope.launch { item.updateMessageBody(messageBody) }
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

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        val aggregatedDeliveryReceipt =
                            item.aggregatedDeliveryReceipt ?: return result.error(
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

    override fun getDetailedDeliveryReceiptList(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<List<Api.DetailedDeliveryReceiptData?>>
    ) {
        debug("getDetailedDeliveryReceiptList => conversationSid: $conversationSid messageIndex: $messageIndex")
        var client = TwilioConversationsPlugin.client ?: return result.error(
            ClientNotInitializedException("Client is not initialized")
        )

        client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
            override fun onSafeSuccess(item: Conversation) {
                item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                    override fun onSafeSuccess(item: Message) {
                        item.getDetailedDeliveryReceiptList(object :
                            SafeCallbackListener<List<DetailedDeliveryReceipt>> {
                            override fun onSafeSuccess(item: List<DetailedDeliveryReceipt>) {
                                debug("getDetailedDeliveryReceiptList => onSuccess")

                                val elements = item.map {
                                    Mapper.detailedDeliveryReceiptToPigeon(it)
                                }

                                return result.success(elements)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("getDetailedDeliveryReceiptList => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        debug("getDetailedDeliveryReceiptList => onError: $errorInfo")
                        result.error(TwilioException(errorInfo.code, errorInfo.message))
                    }
                })
            }
        })
    }
}
