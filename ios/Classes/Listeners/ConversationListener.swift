import Flutter
import TwilioConversationsClient

public class ConversationListener: NSObject, TCHConversationDelegate {
    let events: FlutterEventSink
    
    init(_ events: @escaping FlutterEventSink) {
        self.events = events
    }
    
    // onConversationDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onConversationDeleted => conversationSid = \(String(describing: conversation.sid))")
        sendEvent("conversationDeleted", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any
        ])
    }
    
    // onConversationUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onConversationUpdated => conversationSid = \(String(describing: conversation.sid))")
        sendEvent("conversationUpdated", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any
        ])
    }
    
    // onMessageAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageAdded => messageSid = \(String(describing: message.sid))")
        sendEvent("messageAdded", data: [
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid)
        ])
    }
    
    // onMessageDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageDeleted => messageSid = \(String(describing: message.sid))")
        sendEvent("messageDeleted", data: [
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid)
        ])
    }

    // onMessageUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onMessageUpdated => messageSid = \(String(describing: message.sid)), " +
                "updated = \(String(describing: updated))")
        sendEvent("messageUpdated", data: [
            "message": Mapper.messageToDict(message, conversationSid: conversation.sid),
            "reason": [
                "type": "message",
                "value": Mapper.messageUpdateToString(updated)
            ]
        ])
    }

    // onParticipantDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantDeleted => participantSid = \(String(describing: participant.sid))")
        sendEvent("participantDeleted", data: [
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }
    
    // onParticipantAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantAdded => participantSid = \(String(describing: participant.sid))")
        sendEvent("participantAdded", data: [
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }
    
    // onParticipantUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onParticipantUpdated => participantSid = \(String(describing: participant.sid)), " +
                "updated = \(String(describing: updated))")
        sendEvent("participantUpdated", data: [
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any,
            "reason": [
                "type": "participant",
                "value": Mapper.participantUpdateToString(updated)
            ]
        ])
    }
    
    // onTypingEnded
    public func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingEnded => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        sendEvent("typingEnded", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }

    // onTypingStarted
    public func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onTypingStarted => conversationSid = \(String(describing: conversation.sid)), " +
                "participantSid = \(String(describing: participant.sid))")
        sendEvent("typingStarted", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any,
            "participant": Mapper.participantToDict(participant, conversationSid: conversation.sid) as Any
        ])
    }
    
    // onSynchronizationChanged
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug(
            "ConversationListener.onSynchronizationChanged => conversationSid = \(String(describing: conversation.sid))")
        sendEvent("synchronizationChanged", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any
        ])
    }
    
    //TODO figure out what these listeners are for. Are they duplicates of the ones in ClientListener
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, userSubscribed user: TCHUser) {
        print("conversation.userSubscribed() [NOT IMPLEMENTED]")
    }
    
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, userUnsubscribed user: TCHUser) {
        print("conversation.userUnsubscribed() [NOT IMPLEMENTED]")
    }
    
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, user: TCHUser, updated: TCHUserUpdate) {
        print("conversation.userUpdated() [NOT IMPLEMENTED]")
    }
    
    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData =
            Mapper.encode([
                "name": name,
                "data": data,
                "error": Mapper.errorToDict(error)
            ] as [String: Any?])
        
        events(eventData)
    }
}
