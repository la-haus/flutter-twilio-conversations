package twilio.flutter.twilio_conversations.methods

import com.google.gson.Gson
import com.twilio.conversations.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import java.io.FileInputStream


object MessagesMethods {
    fun getLastMessages(call: MethodCall, result: MethodChannel.Result) {
        val count = call.argument<Int>("count")
                ?: return result.error("ERROR", "Missing 'count'", null)

        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation?) {
                    conversation?.getLastMessages(count, object : CallbackListener<List<Message>> {
                        override fun 
                                onSuccess(messages: List<Message>) {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")

                            val jsonMap = Gson().toJson(messages.map { Mapper.messageToMap(it) })
                            result.success(jsonMap)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.getLastMessages) => onError: $errorInfo")
                            result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                        }
                    })
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        } catch (err: IllegalStateException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }
    fun sendMessage(call: MethodCall, result: MethodChannel.Result) {
        val options = call.argument<Map<String, Any>>("options")
                ?: return result.error("ERROR", "Missing 'options'", null)

        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        val messageOptions = Message.options()
        if (options["body"] != null) {
            messageOptions.withBody(options["body"] as String)
        }

        if (options["inputPath"] != null) {
            val input = options["inputPath"] as String
            val mimeType = options["mimeType"] as String?
                    ?: return result.error("ERROR", "Missing 'mimeType' in MessageOptions", null)

            messageOptions.withMedia(FileInputStream(input), mimeType)
            if (options["filename"] != null) {
                messageOptions.withMediaFileName(options["filename"] as String)
            }
        }

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.sendMessage(messageOptions) { message ->
                        TwilioConversationsPlugin.debug("${call.method} => onSuccess")

                        val jsonMap = Gson().toJson(Mapper.messageToMap(message))
                        result.success(jsonMap)
                    }
                }

                override fun onError(errorInfo: ErrorInfo) {
                    TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                    result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                }
            })
        } catch (err: IllegalArgumentException) {
            return result.error("IllegalArgumentException", err.message, null)
        }
    }

    fun getMessagesBefore(call: MethodCall, result: MethodChannel.Result) {
        val index = call.argument<Int>("index")?.toLong()
                ?: return result.error("ERROR", "Missing 'index'", null)
        val count = call.argument<Int>("count")
                ?: return result.error("ERROR", "Missing 'count'", null)
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.getMessagesBefore(index, count, object : CallbackListener<List<Message>> {
                    override fun onSuccess(messages: List<Message>) {
                        val jsonMap = Gson().toJson(messages.map { Mapper.messageToMap(it) })
                        result.success(jsonMap)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioConversationsPlugin.debug("${call.method} (conversation.getMessagesBefore) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")

                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setAllMessagesRead(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.setAllMessagesRead(object : CallbackListener<Long> {
                    override fun onSuccess(index: Long) {
                        result.success(index)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioConversationsPlugin.debug("${call.method} (conversation.setAllMessagesRead) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun setLastReadMessageIndex(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)
        val lastReadMessageIndex = call.argument<Int>("lastReadMessageIndex")?.toLong()
                ?: return result.error("ERROR", "Missing 'lastReadMessageIndex'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                conversation.setLastReadMessageIndex(lastReadMessageIndex, object : CallbackListener<Long> {
                    override fun onSuccess(newIndex: Long) {
                        result.success(newIndex)
                    }

                    override fun onError(errorInfo: ErrorInfo) {
                        TwilioConversationsPlugin.debug("${call.method} (conversation.setLastReadMessageIndex) => onError: $errorInfo")
                        result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
                    }
                })
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}
