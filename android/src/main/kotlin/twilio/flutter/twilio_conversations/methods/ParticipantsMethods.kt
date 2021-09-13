package twilio.flutter.twilio_conversations.methods

import com.google.gson.Gson
import com.twilio.conversations.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

object ParticipantsMethods {
    fun addParticipantByIdentity(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.addParticipantByIdentity(identity, Attributes(), object : StatusListener {
                        override fun onSuccess() {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.addParticipantByIdentity) => onError: $errorInfo")
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

    fun removeParticipantByIdentity(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)
        val identity = call.argument<String>("identity")
                ?: return result.error("ERROR", "Missing 'identity'", null)

        try {
            TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
                override fun onSuccess(conversation: Conversation) {
                    conversation.removeParticipantByIdentity(identity, object : StatusListener {
                        override fun onSuccess() {
                            TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                            result.success(true)
                        }

                        override fun onError(errorInfo: ErrorInfo) {
                            TwilioConversationsPlugin.debug("${call.method} (conversation.removeParticipantByIdentity) => onError: $errorInfo")
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


    fun getParticipantsList(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("ParticipantsMethods.getParticipantsList (Conversation.getConversation) => onSuccess")
                val participantsListMap = Gson().toJson(Mapper.participantListToMap(conversation.participantsList))
                result.success(participantsListMap)
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun getUsers(call: MethodCall, result: MethodChannel.Result) {
        val conversationSid = call.argument<String>("conversationSid")
                ?: return result.error("ERROR", "Missing 'conversationSid'", null)

        TwilioConversationsPlugin.client?.getConversation(conversationSid, object : CallbackListener<Conversation> {
            override fun onSuccess(conversation: Conversation) {
                TwilioConversationsPlugin.debug("${call.method} => onSuccess")
                val users = mutableListOf<User>()
                conversation.participantsList.forEach {
                    it.getAndSubscribeUser { user ->
                        users.add(user)
                        if (users.size == conversation.participantsList.size) {
                            val userListMap = Gson().toJson(users.mapNotNull { Mapper.userToMap(it) })
                            result.success(userListMap)
                        }
                    }
                }
            }

            override fun onError(errorInfo: ErrorInfo) {
                TwilioConversationsPlugin.debug("${call.method} onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }
}