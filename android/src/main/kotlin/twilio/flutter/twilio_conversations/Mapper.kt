package twilio.flutter.twilio_conversations

import com.twilio.conversations.*
import io.flutter.plugin.common.EventChannel
import twilio.flutter.twilio_conversations.listeners.ConversationListener
import java.text.SimpleDateFormat
import java.util.*

object Mapper {
    //TODO go through all of the mappers in iOS, Android, and Dart, to make sure
    // they are consistent
    fun conversationsClientToMap(client: ConversationsClient): Map<String, Any> {
        return mapOf(
                "myIdentity" to client.myIdentity,
                "connectionState" to client.connectionState.toString(),
                "isReachabilityEnabled" to client.isReachabilityEnabled
        )
    }

    fun attributesToMap(attributes: Attributes): Map<String, Any> {
        return mapOf(
                "type" to attributes.type.toString(),
                "data" to attributes.toString()
        )
    }

    fun conversationsToMap(conversations: MutableList<Conversation>?): List<Map<String, Any?>> {
        if (conversations == null) {
            return listOf(mapOf())
        }
        return conversations.mapNotNull { conversationToMap(it) }
    }

    fun conversationToMap(conversation: Conversation?): Map<String, Any?>? {
        if (conversation == null) return null
        if (!TwilioConversationsPlugin.conversationChannels.containsKey(conversation.sid)) {
            TwilioConversationsPlugin.conversationChannels[conversation.sid] = EventChannel(TwilioConversationsPlugin.messenger, "twilio_conversations/${conversation.sid}")
            TwilioConversationsPlugin.conversationChannels[conversation.sid]?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    TwilioConversationsPlugin.debug("Mapper.conversationToMap => EventChannel for Conversation(${conversation.sid}) attached")
                    TwilioConversationsPlugin.conversationListeners[conversation.sid] = ConversationListener(events)
                    conversation.addListener(TwilioConversationsPlugin.conversationListeners[conversation.sid])
                }

                override fun onCancel(arguments: Any?) {
                    TwilioConversationsPlugin.debug("Mapper.conversationToMap => EventChannel for Conversation(${conversation.sid}) detached")
                    conversation.removeListener(TwilioConversationsPlugin.conversationListeners[conversation.sid])
                    TwilioConversationsPlugin.conversationListeners.remove(conversation.sid)
                }
            })
        }

        return mapOf(
                "attributes" to attributesToMap(conversation.attributes),
                "createdBy" to conversation.createdBy,
                "dateCreated" to dateToString(conversation.dateCreatedAsDate),
                "dateUpdated" to dateToString(conversation.dateUpdatedAsDate),
                "friendlyName" to conversation.friendlyName,
                "lastMessageDate" to dateToString(conversation.lastMessageDate),
                "lastReadMessageIndex" to conversation.lastReadMessageIndex,
                "lastMessageIndex" to conversation.lastMessageIndex,
                "sid" to conversation.sid,
                "status" to conversation.status.toString(),
                "synchronizationStatus" to conversation.synchronizationStatus.toString(),
                "uniqueName" to conversation.uniqueName
        )
    }

    fun messageToMap(message: Message): Map<String, Any?> {
        return mapOf(
                "sid" to message.sid,
                "author" to message.author,
                "dateCreated" to dateToString(message.dateCreatedAsDate),
                "messageBody" to message.messageBody,
                "conversationSid" to message.conversation.sid,
                "participantSid" to message.participantSid,
                "participant" to participantToMap(message.participant),
                "messageIndex" to message.messageIndex,
                "type" to message.type.toString(),
                "media" to mapMedia(message),
                "hasMedia" to message.hasMedia(),
                "attributes" to attributesToMap(message.attributes)
        )
    }

    fun participantListToMap(participants: List<Participant>?): List<Map<String, Any?>> {
        if (participants == null) {
            return listOf(mapOf())
        }
        return participants.mapNotNull { participantToMap(it) }
    }

    fun participantToMap(participant: Participant?): Map<String, Any?>? {
        if (participant == null) {
            return null
        }
        return mapOf(
                "sid" to participant.sid,
                "conversationSid" to participant.conversation.sid,
                "lastReadMessageIndex" to participant.lastReadMessageIndex,
                "lastReadTimestamp" to participant.lastReadTimestamp,
                "dateCreated" to participant.dateCreated,
                "dateUpdated" to participant.dateUpdated,
                "identity" to participant.identity,
                "type" to participant.type.toString()
        )
    }

    fun userToMap(user: User?): Map<String, Any>? {
        if (user == null) return null
        return mapOf(
                "friendlyName" to user.friendlyName,
                "attributes" to attributesToMap(user.attributes),
                "identity" to user.identity,
                "isOnline" to user.isOnline,
                "isNotifiable" to user.isNotifiable,
                "isSubscribed" to user.isSubscribed
        )
    }

    private fun dateToString(date: Date?): String? {
        if (date == null) return null
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss ZZZ")
        return dateFormat.format(date)
    }

    private fun mapMedia(message: Message): Map<String, Any?>? {
        if (!message.hasMedia()) {
            return null
        }

        return mapOf(
                "sid" to message.mediaSid,
                "fileName" to message.mediaFileName,
                "type" to message.mediaType,
                "size" to message.mediaSize,
                "conversationSid" to message.conversationSid,
                "messageIndex" to message.messageIndex

        )
    }

    fun errorInfoToMap(errorInfo: ErrorInfo?): Map<String, Any?>? {
        errorInfo ?: return null

        return mapOf(
                "code" to errorInfo.code,
                "message" to errorInfo.message,
                "status" to errorInfo.status
        )
    }
}
