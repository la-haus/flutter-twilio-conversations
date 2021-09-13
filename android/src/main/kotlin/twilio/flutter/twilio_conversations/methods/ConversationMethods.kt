import com.twilio.conversations.CallbackListener
import com.twilio.conversations.Conversation
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

object ConversationMethods {
    private const val TAG = "ConversationMethods"

    fun join(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.join(object : StatusListener {
                        override fun onSuccess() {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.join) => onError: $errorInfo")
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
        }
    }

    fun leave(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.leave(object : StatusListener {
                        override fun onSuccess() {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.leave) => onError: $errorInfo")
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
        }
    }

    fun typing(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                    conversation.typing()
                    result.success(true)
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

    fun setFriendlyName(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        val friendlyName = call.argument<String>("friendlyName")
                ?: return result.error("ERROR", "Missing 'friendlyName'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.setFriendlyName(friendlyName, object : StatusListener {
                        override fun onSuccess() {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(conversation.friendlyName)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.setFriendlyName) => onError: $errorInfo")
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
        }
    }

    fun getUnreadMessagesCount(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.getUnreadMessagesCount(object : CallbackListener<Long?> {
                        override fun onSuccess(count: Long?) {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(count)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.getUnreadMessagesCount) => onError: $errorInfo")
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
        }
    }
}