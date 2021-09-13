package twilio.flutter.twilio_conversations.listeners

import com.google.gson.Gson
import com.twilio.conversations.*
import io.flutter.plugin.common.EventChannel
import twilio.flutter.twilio_conversations.Mapper
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin

class ClientListener : ConversationsClientListener {
    var events: EventChannel.EventSink? = null

    fun onListen() {
        sendEvent("clientListenerAttached")
    }

    override fun onClientSynchronization(status: ConversationsClient.SynchronizationStatus) {
        TwilioConversationsPlugin.debug("ClientListener.onClientSynchronization => status = $status")
        sendEvent("clientSynchronization", mapOf("synchronizationStatus" to status.toString()))
    }

    override fun onConversationSynchronizationChange(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationSynchronizationChange => sid = ${conversation.sid}")
        sendEvent("conversationSynchronizationChange", mapOf("conversation" to Mapper.conversationToMap(conversation)))
    }

    override fun onNotificationSubscribed() {
        TwilioConversationsPlugin.debug("ClientListener.onNotificationSubscribed")
        sendEvent("notificationSubscribed")
    }

    override fun onUserSubscribed(user: User?) {
        TwilioConversationsPlugin.debug("ClientListener.onUserSubscribed => user '${user?.friendlyName}'")
        sendEvent("userSubscribed", mapOf("user" to Mapper.userToMap(user)))
    }

    override fun onUserUnsubscribed(user: User?) {
        TwilioConversationsPlugin.debug("ClientListener.onUserUnsubscribed => user '${user?.friendlyName}'")
        sendEvent("userUnsubscribed", mapOf("user" to Mapper.userToMap(user)))
    }

    override fun onUserUpdated(user: User?, reason: User.UpdateReason?) {
        TwilioConversationsPlugin.debug("ClientListener.onUserUpdated => user '${user?.friendlyName}' updated, $reason")
        sendEvent("userUpdated", mapOf(
                "user" to Mapper.userToMap(user),
                "reason" to mapOf(
                        "type" to "user",
                        "value" to reason.toString()
                )
        ))
    }

    override fun onNotificationFailed(errorInfo: ErrorInfo?) {
        sendEvent("notificationFailed", null, errorInfo)
    }

    override fun onTokenExpired() {
        TwilioConversationsPlugin.debug("ClientListener.onTokenExpired")
        sendEvent("tokenExpired")
    }

    override fun onConversationUpdated(conversation: Conversation?, reason: Conversation.UpdateReason?) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationUpdated => conversation '${conversation?.sid}' updated, $reason")
        sendEvent("conversationUpdated", mapOf(
                "conversation" to Mapper.conversationToMap(conversation),
                "reason" to mapOf(
                        "type" to "conversation",
                        "value" to reason.toString()
                )
        ))
    }

    override fun onConversationAdded(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationAdded => sid = ${conversation.sid}")
        sendEvent("conversationAdded", mapOf("conversation" to Mapper.conversationToMap(conversation)))
    }

    override fun onNewMessageNotification(conversationSid: String?, messageSid: String?, messageIndex: Long) {
        TwilioConversationsPlugin.debug("ClientListener.onNewMessageNotification => conversationSid = $conversationSid, messageSid = $messageSid, messageIndex = $messageIndex")
        sendEvent("newMessageNotification", mapOf(
                "conversationSid" to conversationSid,
                "messageSid" to messageSid,
                "messageIndex" to messageIndex
        ))
    }

    override fun onAddedToConversationNotification(conversationSid: String?) {
        TwilioConversationsPlugin.debug("ClientListener.onAddedToConversationNotification => conversationSid = $conversationSid")
        sendEvent("addedToConversationNotification", mapOf("conversationSid" to conversationSid))
    }

    override fun onConnectionStateChange(state: ConversationsClient.ConnectionState) {
        TwilioConversationsPlugin.debug("ClientListener.onConnectionStateChange => state = $state")
        sendEvent("connectionStateChange", mapOf("connectionState" to state.toString()))
    }

    override fun onError(errorInfo: ErrorInfo?) {
        sendEvent("error", null, errorInfo)
    }

    override fun onConversationDeleted(conversation: Conversation) {
        TwilioConversationsPlugin.debug("ClientListener.onConversationDeleted => sid = ${conversation.sid}")
        sendEvent("conversationDeleted", mapOf("conversation" to Mapper.conversationToMap(conversation)))
    }

    override fun onRemovedFromConversationNotification(conversationSid: String?) {
        TwilioConversationsPlugin.debug("ClientListener.onRemovedFromConversationNotification => conversationSid = $conversationSid")
        sendEvent("removedFromConversationNotification", mapOf("conversationSid" to conversationSid))
    }

    override fun onTokenAboutToExpire() {
        TwilioConversationsPlugin.debug("ClientListener.onTokenAboutToExpire")
        sendEvent("tokenAboutToExpire")
    }

    private fun sendEvent(name: String, data: Any? = null, e: ErrorInfo? = null) {
        val eventData = Gson().toJson(mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e)))
        events?.success(eventData)
    }
}