import TwilioConversationsClient

public class ClientListener: NSObject, TwilioConversationsClientDelegate {
    let TAG = "ClientListener"

    // onAddedToConversation Notification
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        notificationAddedToConversationWithSid conversationSid: String) {
        debug("onAddedToConversationNotification => conversationSid is \(conversationSid)'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.added(
            toConversationNotificationConversationSid: conversationSid, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onAddedToConversationNotification => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onClientSynchronizationUpdated
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        debug("onClientSynchronization => state is \(Mapper.clientSynchronizationStatusToString(status))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.clientSynchronizationSynchronizationStatus(
            Mapper.clientSynchronizationStatusToString(status), completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onClientSynchronization => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onConnectionStateChange
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        connectionStateUpdated state: TCHClientConnectionState) {
        debug("onConnectionStateChange => state is \(Mapper.clientConnectionStateToString(state))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.connectionStateChangeConnectionState(
            Mapper.clientConnectionStateToString(state), completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onConnectionStateChange => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onConversationAdded
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        conversationAdded conversation: TCHConversation) {
        debug("onConversationAdded => conversation \(String(describing: conversation.sid))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationAddedConversationData(
            Mapper.conversationToPigeon(conversation)!, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onConversationAdded => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onConversationDeleted
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        conversationDeleted conversation: TCHConversation) {
        debug("onConversationDeleted => conversation \(String(describing: conversation.sid))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationDeletedConversationData(
            Mapper.conversationToPigeon(conversation)!, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onConversationDeleted => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onConversationSynchronizationChanged
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        conversation: TCHConversation,
        synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        debug("onConversationSynchronizationChange => conversationSid is '\(String(describing: conversation.sid))', "
              + "syncStatus: \(Mapper.conversationSynchronizationStatusToString(conversation.synchronizationStatus))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationSynchronizationChange(
            Mapper.conversationToPigeon(conversation)!, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onConversationSynchronizationChange => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onConversationUpdated
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        conversation: TCHConversation,
        updated: TCHConversationUpdate) {
        debug("conversationUpdated => conversation "
              + "\(String(describing: conversation.sid)) updated, \(Mapper.conversationUpdateToString(updated))")

        let event = TWCONConversationUpdatedData()
        event.conversation = Mapper.conversationToPigeon(conversation)
        event.reason = Mapper.conversationUpdateToString(updated)

        SwiftTwilioConversationsPlugin.flutterClientApi?.conversationUpdatedEvent(
            event,
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("conversationUpdated => "
                            + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onError
    public func conversationsClient(_ client: TwilioConversationsClient, errorReceived error: TCHError) {
        debug("onError")
        SwiftTwilioConversationsPlugin.flutterClientApi?.errorErrorInfoData(
            Mapper.errorToPigeon(error), completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onError => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onNewMessageNotification
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        notificationNewMessageReceivedForConversationSid conversationSid: String,
        messageIndex: UInt) {
        debug("onNewMessageNotification => conversationSid: \(conversationSid), messageIndex: \(messageIndex)")
        SwiftTwilioConversationsPlugin.flutterClientApi?.newMessageNotificationConversationSid(
            conversationSid,
            messageIndex: NSNumber(value: messageIndex),
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onNewMessageNotification => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onRemovedFromConversationNotification
    public func conversationsClient(
        _ client: TwilioConversationsClient,
        notificationRemovedFromConversationWithSid conversationSid: String) {
        debug("onRemovedFromConversationNotification => conversationSid: \(conversationSid)")
        SwiftTwilioConversationsPlugin.flutterClientApi?.removed(
            fromConversationNotificationConversationSid: conversationSid,
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onRemovedFromConversationNotification => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onTokenExpired
    public func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        debug("onTokenExpired")
        SwiftTwilioConversationsPlugin.flutterClientApi?.tokenExpired(
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onTokenExpired => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onTokenAboutToExpire
    public func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        debug("onTokenAboutToExpire")
        SwiftTwilioConversationsPlugin.flutterClientApi?.tokenAboutToExpire(
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onTokenAboutToExpire => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onUserSubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userSubscribed user: TCHUser) {
        debug("onUserSubscribed => user '\(String(describing: user.identity))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userSubscribedUserData(
            Mapper.userToPigeon(user)!, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onUserSubscribed => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onUserUnsubscribed
    public func conversationsClient(_ client: TwilioConversationsClient, userUnsubscribed user: TCHUser) {
        debug("onUserUnsubscribed => user '\(String(describing: user.identity))'")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userUnsubscribedUserData(
            Mapper.userToPigeon(user)!, completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onUserUnsubscribed => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    // onUserUpdated
    public func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated: TCHUserUpdate) {
        debug("onUserUpdated => user \(String(describing: user.identity)) "
              + "updated, \(Mapper.userUpdateToString(updated))")
        SwiftTwilioConversationsPlugin.flutterClientApi?.userUpdatedUserData(
            Mapper.userToPigeon(user)!,
            reason: Mapper.userUpdateToString(updated),
            completion: { (error: Error?) in
                if let errorMessage = error {
                    self.debug("onUserUpdated => "
                        + "Error calling FlutterClientApi: \(errorMessage)")
                }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
