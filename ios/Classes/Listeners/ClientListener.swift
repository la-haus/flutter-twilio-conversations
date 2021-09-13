import TwilioConversationsClient

public class ClientListener: NSObject, TwilioConversationsClientDelegate {
    public var events: FlutterEventSink?

    public var client: TwilioConversationsClient?
    
    public func onListen() {
        sendEvent("clientListenerAttached")
    }

    // onAddedToConversation Notification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationAddedToConversationWithSid conversationSid: String) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onAddedToConversationNotification => conversationSid is \(conversationSid)'")
        sendEvent("addedToConversationNotification", data: ["conversationSid": conversationSid])
    }
    
    // onClientSynchronizationUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onClientSynchronization => state is \(Mapper.clientSynchronizationStatusToString(status))")
        sendEvent("clientSynchronization", data: ["synchronizationStatus": Mapper.clientSynchronizationStatusToString(status)])
    }
    
    // onConnectionStateChange
    public func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConnectionStateChange => state is \(Mapper.clientConnectionStateToString(state))")
        sendEvent("connectionStateChange", data: ["connectionState": Mapper.clientConnectionStateToString(state)])
    }

    // onConversationAdded
    public func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationAdded => conversationSid is \(String(describing: conversation.sid))'")
        sendEvent("conversationAdded", data: ["conversation": Mapper.conversationToDict(conversation) as Any])
    }
    
    // onConversationDeleted
    public func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationDeleted => conversationSid is \(String(describing: conversation.sid))'")
        sendEvent("conversationDeleted", data: ["conversation": Mapper.conversationToDict(conversation) as Any])
    }
    
    // onConversationSynchronizationChanged
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onConversationSynchronizationChange => conversationSid is '\(String(describing: conversation.sid))', syncStatus: \(Mapper.conversationSynchronizationStatusToString(conversation.synchronizationStatus))")
        sendEvent("conversationSynchronizationChange", data: ["conversation": Mapper.conversationToDict(conversation) as Any])
    }
    
    // onConversationUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.conversationUpdated => conversationSid is \(String(describing: conversation.sid)) updated, \(Mapper.conversationUpdateToString(updated))")
        sendEvent("conversationUpdated", data: [
            "conversation": Mapper.conversationToDict(conversation) as Any,
            "reason": [
                "type": "conversation",
                "value": Mapper.conversationUpdateToString(updated)
            ]
        ])
    }
    
    // onError
    public func conversationsClient(_ client: TwilioConversationsClient, errorReceived error: TCHError) {
        sendEvent("error", error: error)
    }
    
    // onNewMessageNotification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationNewMessageReceivedForConversationSid conversationSid: String, messageIndex: UInt) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onNewMessageNotification => conversationSid: \(conversationSid), messageIndex: \(messageIndex)")
        var messageSid: String = ""
        client.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.message(withIndex: messageIndex as NSNumber, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful, let sid = message?.sid {
                        messageSid = sid
                    }
                })
            }
        })
        sendEvent("newMessageNotification", data: [
            "conversationSid": conversationSid,
            "messageSid": messageSid,
            "messageIndex": messageIndex
        ])
    }

    
    // onRemovedFromConversationNotification
    public func conversationsClient(_ client: TwilioConversationsClient, notificationRemovedFromConversationWithSid conversationSid: String) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onRemovedFromConversationNotification => conversationSid: \(conversationSid)")
        sendEvent("removedFromConversationNotification", data: ["conversationSid": conversationSid])
    }

    // onTokenExpired
    public func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onTokenExpired")
        sendEvent("tokenExpired", data: nil)
    }
    
    // onTokenAboutToExpire
    public func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onTokenAboutToExpire")
        sendEvent("tokenAboutToExpire", data: nil)
    }
    
    // onUserSubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userSubscribed user: TCHUser) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserSubscribed => user '\(String(describing: user.identity))'")
        sendEvent("userSubscribed", data: ["user": Mapper.userToDict(user) as Any])
    }
    
    // onUserUnsubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userUnsubscribed user: TCHUser) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserUnsubscribed => user '\(String(describing: user.identity))'")
        sendEvent("userUnsubscribed", data: ["user": Mapper.userToDict(user) as Any])
    }
    
    // onUserUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated: TCHUserUpdate) {
        SwiftTwilioConversationsPlugin.debug("ClientListener.onUserUpdated => user \(String(describing: user.identity)) updated, \(Mapper.userUpdateToString(updated))")
        sendEvent("userUpdated", data: [
            "user": Mapper.userToDict(user) as Any,
            "reason": [
                "type": "user",
                "value": Mapper.userUpdateToString(updated)
            ]
        ])
    }

    private func errorToDict(_ error: Error?) -> [String: Any]? {
        if let error = error as NSError? {
            return [
                "code": error.code,
                "message": error.description
            ]
        }
        return nil
    }
    
    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = ["name": name, "data": data, "error": errorToDict(error)] as [String: Any?]
        
        if let events = events {
            events(Mapper.encode(eventData))
        }
    }
}
