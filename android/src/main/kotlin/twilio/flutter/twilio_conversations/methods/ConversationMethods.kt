import com.twilio.conversations.Attributes
import com.twilio.conversations.Conversation
import com.twilio.util.ErrorInfo
import com.twilio.conversations.Message
import com.twilio.conversations.extensions.sendMessage
import java.io.FileInputStream
import twilio.flutter.twilio_conversations.Api
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import twilio.flutter.twilio_conversations.exceptions.ClientNotInitializedException
import twilio.flutter.twilio_conversations.exceptions.ConversionException
import twilio.flutter.twilio_conversations.exceptions.NotFoundException
import twilio.flutter.twilio_conversations.exceptions.TwilioException
import twilio.flutter.twilio_conversations.listeners.SafeCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeNullableCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeSuspendCallbackListener
import twilio.flutter.twilio_conversations.listeners.SafeStatusListener

class ConversationMethods : Api.ConversationApi {
    private val TAG = "ConversationMethods"

    override fun join(conversationSid: String, result: Api.Result<Void>) {
        debug("join => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object :
                SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.join(object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("join => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("join => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("join => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("join => onError: $err")
            return result.error(err)
        }
    }

    override fun leave(conversationSid: String, result: Api.Result<Void>) {
        debug("leave => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.leave(object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("leave => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("leave => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("leave => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("leave => onError: $err")
            return result.error(err)
        }
    }

    override fun destroy(conversationSid: String, result: Api.Result<Void>) {
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.destroy(object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("destroy => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("destroy => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("destroy => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("destroy => onError: $err")
            return result.error(err)
        }
    }

    override fun typing(conversationSid: String, result: Api.Result<Void>) {
        debug("typing => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    debug("typing => onSuccess")
                    item.typing()
                    result.success(null)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("typing => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("typing => onError: $err")
            return result.error(err)
        }
    }

    override fun sendMessage(
        conversationSid: String,
        options: Api.MessageOptionsData,
        result: Api.Result<Api.MessageData>
    ) {
        debug("sendMessage => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeSuspendCallbackListener<Conversation> {
                override suspend fun onSafeSuccess(item: Conversation) {
                    val message = item.sendMessage {
                        this.body = options.body

                        val attributes = options.attributes
                        if (attributes != null) {
                            val mappedAttributes = Mapper.pigeonToAttributes(attributes)
                            if (mappedAttributes != null) {
                                this.attributes = mappedAttributes
                            }
                        }

                        val inputPath = options.inputPath
                        val mimeType = options.mimeType
                        if (inputPath != null && mimeType != null) {
                            val filename = options.filename

                            if (filename != null) {
                                addMedia(FileInputStream(inputPath), mimeType, filename)
                            } else {
                                addMedia(FileInputStream(inputPath), mimeType)
                            }
                        }
                    }

                    debug("sendMessage => onSuccess")
                    val messageData = Mapper.messageToPigeon(message)
                    result.success(messageData)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("sendMessage => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("sendMessage => onError: $err")
            return result.error(err)
        }
    }

    override fun addParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Boolean>
    ) {
        debug("addParticipantByIdentity => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.addParticipantByIdentity(identity, Attributes(), object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("addParticipantByIdentity => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("addParticipantByIdentity => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("addParticipantByIdentity => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("addParticipantByIdentity => onError: $err")
            return result.error(err)
        }
    }

    override fun removeParticipant(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Boolean>
    ) {
        debug("removeParticipant => conversationSid: $conversationSid participantSid: $participantSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantBySid(participantSid)
                        ?: return result.error(NotFoundException("Participant $participantSid not found."))

                    item.removeParticipant(participant, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("removeParticipant => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("removeParticipant => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("removeParticipant => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("removeParticipant => onError: $err")
            return result.error(err)
        }
    }

    override fun removeParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Boolean>
    ) {
        debug("removeParticipantByIdentity => conversationSid: $conversationSid identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.removeParticipantByIdentity(identity, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("removeParticipantByIdentity => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("removeParticipantByIdentity => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("removeParticipantByIdentity => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("removeParticipantByIdentity => onError: $err")
            return result.error(err)
        }
    }

    override fun getParticipantByIdentity(
        conversationSid: String,
        identity: String,
        result: Api.Result<Api.ParticipantData>
    ) {
        debug("getParticipantByIdentity => conversationSid: $conversationSid identity: $identity")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantByIdentity(identity)
                        ?: return result.error(NotFoundException("No participant found with identity $identity"))
                    debug("getParticipantByIdentity => onSuccess")
                    val participantData = Mapper.participantToPigeon(participant)
                    result.success(participantData)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getParticipantByIdentity => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getParticipantByIdentity => onError: $err")
            return result.error(err)
        }
    }

    override fun getParticipantBySid(
        conversationSid: String,
        participantSid: String,
        result: Api.Result<Api.ParticipantData>
    ) {
        debug("getParticipantBySid => conversationSid: $conversationSid participantSid: $participantSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val participant = item.getParticipantBySid(participantSid)
                        ?: return result.error(NotFoundException("No participant found with sid $participantSid"))
                    debug("getParticipantBySid => onSuccess")
                    val participantData = Mapper.participantToPigeon(participant)
                    result.success(participantData)
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getParticipantBySid => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getParticipantBySid => onError: $err")
            return result.error(err)
        }
    }

    override fun getParticipantsList(
        conversationSid: String,
        result: Api.Result<MutableList<Api.ParticipantData>>
    ) {
        debug("getParticipantsList => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    debug("getParticipantsList => onSuccess")
                    val participantsListData = Mapper.participantListToPigeon(item.participantsList)
                    result.success(participantsListData.toMutableList())
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getParticipantsList => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getParticipantsList => onError: $err")
            return result.error(err)
        }
    }

    override fun getMessagesCount(conversationSid: String, result: Api.Result<Api.MessageCount>) {
        debug("getMessagesCount => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    debug("getMessagesCount => onSuccess")
                    item.getMessagesCount(object : SafeCallbackListener<Long> {
                        override fun onSafeSuccess(item: Long) {
                            debug("getMessagesCount => onSuccess: $item")
                            val count = Api.MessageCount()
                            count.count = item
                            result.success(count)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getMessagesCount => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getMessagesCount => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getMessagesCount => onError: $err")
            return result.error(err)
        }
    }

    override fun getUnreadMessagesCount(conversationSid: String, result: Api.Result<Long>) {
        debug("getUnreadMessagesCount => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.getUnreadMessagesCount(object : SafeNullableCallbackListener<Long> {
                        override fun onSafeSuccess(item: Long?) {
                            debug("getUnreadMessagesCount => onSuccess: $item")
                            result.success(item ?: 0)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getUnreadMessagesCount => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getUnreadMessagesCount => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getUnreadMessagesCount => onError: $err")
            return result.error(err)
        }
    }

    override fun advanceLastReadMessageIndex(
        conversationSid: String,
        lastReadMessageIndex: Long,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("advanceLastReadMessageIndex => conversationSid: $conversationSid index: $lastReadMessageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.advanceLastReadMessageIndex(
                        lastReadMessageIndex,
                        object : SafeCallbackListener<Long> {
                            override fun onSafeSuccess(item: Long) {
                                debug("advanceLastReadMessageIndex => onSuccess")
                                val unreadMessages = Api.MessageCount()
                                unreadMessages.count = item
                                result.success(unreadMessages)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("advanceLastReadMessageIndex => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("advanceLastReadMessageIndex => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("advanceLastReadMessageIndex => onError: $err")
            return result.error(err)
        }
    }

    override fun setLastReadMessageIndex(
        conversationSid: String,
        lastReadMessageIndex: Long,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setLastReadMessageIndex => conversationSid: $conversationSid index: $lastReadMessageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setLastReadMessageIndex(
                        lastReadMessageIndex,
                        object : SafeCallbackListener<Long> {
                            override fun onSafeSuccess(item: Long) {
                                debug("setLastReadMessageIndex => onSuccess")
                                val unreadMessages = Api.MessageCount()
                                unreadMessages.count = item
                                result.success(unreadMessages)
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("setLastReadMessageIndex => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setLastReadMessageIndex => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setLastReadMessageIndex => onError: $err")
            return result.error(err)
        }
    }

    override fun setAllMessagesRead(
        conversationSid: String,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setAllMessagesRead => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setAllMessagesRead(object : SafeCallbackListener<Long> {
                        override fun onSafeSuccess(item: Long) {
                            debug("setAllMessagesRead => onSuccess")
                            val unreadMessages = Api.MessageCount()
                            unreadMessages.count = item
                            result.success(unreadMessages)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setAllMessagesRead => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setAllMessagesRead => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setAllMessagesRead => onError: $err")
            return result.error(err)
        }
    }

    override fun setAllMessagesUnread(
        conversationSid: String,
        result: Api.Result<Api.MessageCount>
    ) {
        debug("setAllMessagesUnread => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setAllMessagesUnread(object : SafeCallbackListener<Long> {
                        override fun onSafeSuccess(item: Long) {
                            debug("setAllMessagesUnread => onSuccess: $item")
                            val unreadMessages = Api.MessageCount()
                            unreadMessages.count = item
                            result.success(unreadMessages)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setAllMessagesUnread => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setAllMessagesUnread => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setAllMessagesUnread => onError: $err")
            return result.error(err)
        }
    }

    override fun getParticipantsCount(conversationSid: String, result: Api.Result<Long>) {
        debug("getParticipantsCount => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    debug("getParticipantsCount => onSuccess")
                    item.getParticipantsCount(object : SafeCallbackListener<Long> {
                        override fun onSafeSuccess(item: Long) {
                            debug("getParticipantsCount => onSuccess: $item")
                            result.success(item)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getParticipantsCount => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getParticipantsCount => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getParticipantsCount => onError: $err")
            return result.error(err)
        }
    }

    override fun setAttributes(
        conversationSid: String,
        attributes: Api.AttributesData,
        result: Api.Result<Void>
    ) {
        debug("setAttributes => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))
        val conversationAttributes = Mapper.pigeonToAttributes(attributes)
            ?: return result.error(ConversionException("Could not convert $attributes to valid Attributes"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setAttributes(conversationAttributes, object : SafeStatusListener {
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

    override fun removeMessage(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<Boolean>
    ) {
        debug("removeMessage => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    val conversation = item

                    conversation.getMessageByIndex(
                        messageIndex,
                        object : SafeCallbackListener<Message> {
                            override fun onSafeSuccess(item: Message) {
                                conversation.removeMessage(item, object : SafeStatusListener {
                                    override fun onSafeSuccess() {
                                        debug("removeMessage => onSuccess")
                                        result.success(true)
                                    }

                                    override fun onError(errorInfo: ErrorInfo) {
                                        debug("removeMessage => onError: $errorInfo")
                                        result.error(
                                            TwilioException(
                                                errorInfo.code,
                                                errorInfo.message
                                            )
                                        )
                                    }
                                })
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("removeMessage => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("removeMessage => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("removeMessage => onError: $err")
            return result.error(err)
        }
    }

    override fun getMessagesAfter(
        conversationSid: String,
        index: Long,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getMessagesAfter => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.getMessagesAfter(
                        index,
                        count.toInt(),
                        object : SafeCallbackListener<List<Message>> {
                            override fun onSafeSuccess(item: List<Message>) {
                                debug("getMessagesAfter => onSuccess")
                                val messagesMap = item.map { Mapper.messageToPigeon(it) }
                                result.success(messagesMap.toMutableList())
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("getMessagesAfter => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getMessagesAfter => onError: $errorInfo")

                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getMessagesAfter => onError: $err")
            return result.error(err)
        }
    }

    override fun getMessagesBefore(
        conversationSid: String,
        index: Long,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getMessagesBefore => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.getMessagesBefore(
                        index,
                        count.toInt(),
                        object : SafeCallbackListener<List<Message>> {
                            override fun onSafeSuccess(item: List<Message>) {
                                debug("getMessagesBefore => onSuccess")
                                val messagesMap = item.map { Mapper.messageToPigeon(it) }
                                result.success(messagesMap.toMutableList())
                            }

                            override fun onError(errorInfo: ErrorInfo) {
                                debug("getMessagesBefore => onError: $errorInfo")
                                result.error(TwilioException(errorInfo.code, errorInfo.message))
                            }
                        })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getMessagesBefore => onError: $errorInfo")

                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getMessagesBefore => onError: $err")
            return result.error(err)
        }
    }

    override fun getMessageByIndex(
        conversationSid: String,
        messageIndex: Long,
        result: Api.Result<Api.MessageData>
    ) {
        debug("getMessageByIndex => conversationSid: $conversationSid messageIndex: $messageIndex")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.getMessageByIndex(messageIndex, object : SafeCallbackListener<Message> {
                        override fun onSafeSuccess(item: Message) {
                            // Android SDK seems to think it's fine to return a different message
                            // if one with the given `messageIndex` does not exist. iOS throws
                            // an exception as one might expect.
                            // Therefore, we do some validation here on the Android side and throw
                            // an exception in order to achieve behaviour that is consistent across platforms.
                            if (item.messageIndex == messageIndex) {
                                debug("getMessageByIndex => onSuccess")
                                result.success(Mapper.messageToPigeon(item))
                            } else {
                                debug("getMessageByIndex => onError: No message found with messageIndex: $messageIndex")
                                result.error(NotFoundException("No message found with messageIndex: $messageIndex"))
                            }
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getMessageByIndex => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getMessageByIndex => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getMessageByIndex => onError: $err")
            return result.error(err)
        }
    }

    override fun getLastMessages(
        conversationSid: String,
        count: Long,
        result: Api.Result<MutableList<Api.MessageData>>
    ) {
        debug("getLastMessages => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.getLastMessages(count.toInt(), object : SafeCallbackListener<List<Message>> {
                        override fun onSafeSuccess(item: List<Message>) {
                            debug("getLastMessages => onSuccess")

                            val messagesMap = item.map { Mapper.messageToPigeon(it) }
                            result.success(messagesMap.toMutableList())
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("getLastMessages => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("getLastMessages => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("getLastMessages => onError: $err")
            return result.error(err)
        }
    }

    override fun setFriendlyName(
        conversationSid: String,
        friendlyName: String,
        result: Api.Result<Void>
    ) {
        debug("setFriendlyName => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
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

    override fun setNotificationLevel(
        conversationSid: String,
        notificationLevel: String,
        result: Api.Result<Void>
    ) {
        debug("setNotificationLevel => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        val level = Mapper.stringToNotificationLevel(notificationLevel)
            ?: return result.error(ConversionException("Unknown notification level $notificationLevel."))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setNotificationLevel(level, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("setNotificationLevel => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setNotificationLevel => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setNotificationLevel => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setNotificationLevel => onError: $err")
            return result.error(err)
        }
    }

    override fun setUniqueName(
        conversationSid: String,
        uniqueName: String,
        result: Api.Result<Void>
    ) {
        debug("setUniqueName => conversationSid: $conversationSid")
        val client = TwilioConversationsPlugin.client
            ?: return result.error(ClientNotInitializedException("Client is not initialized"))

        try {
            client.getConversation(conversationSid, object : SafeCallbackListener<Conversation> {
                override fun onSafeSuccess(item: Conversation) {
                    item.setUniqueName(uniqueName, object : SafeStatusListener {
                        override fun onSafeSuccess() {
                            debug("setUniqueName => onSuccess")
                            result.success(null)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            debug("setUniqueName => onError: $errorInfo")
                            result.error(TwilioException(errorInfo.code, errorInfo.message))
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    debug("setUniqueName => onError: $errorInfo")
                    result.error(TwilioException(errorInfo.code, errorInfo.message))
                }
            })
        } catch (err: Exception) {
            debug("setUniqueName => onError: $err")
            return result.error(err)
        }
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
