package twilio.flutter.twilio_conversations

import com.twilio.conversations.Attributes
import com.twilio.conversations.Conversation
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.Message
import com.twilio.conversations.Participant
import com.twilio.conversations.User
import java.text.SimpleDateFormat
import java.util.Date
import org.json.JSONArray
import org.json.JSONObject
import twilio.flutter.twilio_conversations.listeners.ConversationListener

object Mapper {
    private const val TAG = "Mapper"

    // TODO go through all of the mappers in iOS, Android, and Dart, to make sure they are consistent
    fun conversationsClientToPigeon(client: ConversationsClient): Api.ConversationClientData {
        val result = Api.ConversationClientData()
        result.myIdentity = client.myIdentity
        result.connectionState = client.connectionState.toString()
        result.isReachabilityEnabled = client.isReachabilityEnabled
        return result
    }

    fun attributesToPigeon(attributes: Attributes): Api.AttributesData {
        val result = Api.AttributesData()
        result.type = attributes.type.toString()
        result.data = attributes.toString()
        return result
    }

    fun pigeonToAttributes(pigeon: Api.AttributesData): Attributes? {
        var result: Attributes? = null
        when (pigeon.type) {
            "NULL" ->
                result = Attributes()
            "NUMBER" -> {
                val number: Number =
                    if (pigeon.data.contains('.')) pigeon.data.toFloat()
                    else pigeon.data.toInt()
                result = Attributes(number)
            }
            "STRING" ->
                result = Attributes(pigeon.data)
            "OBJECT" ->
                result = Attributes(JSONObject(pigeon.data))
            "ARRAY" ->
                result = Attributes(JSONArray(pigeon.data))
        }
        return result
    }

    fun conversationsListToPigeon(conversations: MutableList<Conversation>?): List<Api.ConversationData> {
        if (conversations == null) {
            return listOf()
        }
        return conversations.mapNotNull { conversationToPigeon(it) }
    }

    fun conversationToPigeon(conversation: Conversation?): Api.ConversationData? {
        if (conversation == null) return null

        // Setting flutter event listener for the given channel if one does not yet exist.
        if (conversation.sid != null && !TwilioConversationsPlugin.conversationListeners.containsKey(conversation.sid)) {
            debug("setupConversationListener => conversation: ${conversation.sid}")
            TwilioConversationsPlugin.conversationListeners[conversation.sid] = ConversationListener(conversation.sid)
            conversation.addListener(TwilioConversationsPlugin.conversationListeners[conversation.sid])
        }

        val result = Api.ConversationData()
        result.createdBy = conversation.createdBy
        result.dateCreated = dateToString(conversation.dateCreatedAsDate)
        result.dateUpdated = dateToString(conversation.dateUpdatedAsDate)
        result.friendlyName = conversation.friendlyName
        result.lastMessageDate = dateToString(conversation.lastMessageDate)
        result.lastReadMessageIndex =
            if (conversation.synchronizationStatus.isAtLeast(Conversation.SynchronizationStatus.METADATA))
                conversation.lastReadMessageIndex else null
        result.lastMessageIndex = conversation.lastMessageIndex
        result.sid = conversation.sid
        result.status = conversation.status.toString()
        result.synchronizationStatus = conversation.synchronizationStatus.toString()
        result.uniqueName = conversation.uniqueName

        result.attributes = attributesToPigeon(conversation.attributes)

        return result
    }

    fun messageToPigeon(message: Message): Api.MessageData {
        val result = Api.MessageData()

        result.sid = message.sid
        result.author = message.author
        result.dateCreated = dateToString(message.dateCreatedAsDate)
        result.dateUpdated = dateToString(message.dateUpdatedAsDate)
        result.lastUpdatedBy = message.lastUpdatedBy
        result.subject = message.subject
        result.messageBody = message.messageBody
        result.conversationSid = message.conversation.sid
        result.participantSid = message.participantSid
//        result.participant = participantToMap(message.participant)
        result.messageIndex = message.messageIndex
        result.type = message.type.toString()
        result.media = mediaToPigeon(message)
        result.hasMedia = message.hasMedia()
        result.attributes = attributesToPigeon(message.attributes)
        return result
    }

    fun participantListToPigeon(participants: List<Participant>?): List<Api.ParticipantData> {
        if (participants == null) {
            return listOf()
        }
        return participants.mapNotNull { participantToPigeon(it) }
    }

    fun participantToPigeon(participant: Participant?): Api.ParticipantData? {
        if (participant == null) {
            return null
        }
        val result = Api.ParticipantData()
                result.sid = participant.sid
        result.conversationSid = participant.conversation.sid
        result.lastReadMessageIndex = participant.lastReadMessageIndex
        result.lastReadTimestamp = participant.lastReadTimestamp
        result.dateCreated = participant.dateCreated
        result.dateUpdated = participant.dateUpdated
        result.identity = participant.identity
        result.type = participant.type.toString()
        result.attributes = attributesToPigeon(participant.attributes)
        return result
    }

    fun userToPigeon(user: User?): Api.UserData? {
        if (user == null) return null
        val result = Api.UserData()

        result.friendlyName = user.friendlyName
        result.attributes = attributesToPigeon(user.attributes)
        result.identity = user.identity
        result.isOnline = user.isOnline
        result.isNotifiable = user.isNotifiable
        result.isSubscribed = user.isSubscribed
        return result
    }

    private fun dateToString(date: Date?): String? {
        if (date == null) return null
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss ZZZ")
        return dateFormat.format(date)
    }

    fun mediaToPigeon(message: Message): Api.MessageMediaData? {
        if (!message.hasMedia()) {
            return null
        }

        val result = Api.MessageMediaData()
        result.sid = message.mediaSid
        result.fileName = message.mediaFileName
        result.type = message.mediaType
        result.size = message.mediaSize
        result.conversationSid = message.conversationSid
        result.messageIndex = message.messageIndex
        result.messageSid = message.sid
        return result
    }

    fun errorInfoToPigeon(errorInfo: ErrorInfo): Api.ErrorInfoData {
        val errorData = Api.ErrorInfoData()
        errorData.status = errorInfo.status.toLong()
        errorData.message = errorInfo.message
        errorData.code = errorInfo.code.toLong()
        return errorData
    }

    fun stringToNotificationLevel(level: String): Conversation.NotificationLevel? {
        var result: Conversation.NotificationLevel? = null
        when (level) {
            "DEFAULT" ->
                result = Conversation.NotificationLevel.DEFAULT
            "MUTED" ->
                result = Conversation.NotificationLevel.MUTED
        }
        return result
    }

    fun debug(message: String) {
        TwilioConversationsPlugin.debug("$TAG::$message")
    }
}
