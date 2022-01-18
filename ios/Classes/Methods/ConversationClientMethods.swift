import Flutter
import TwilioConversationsClient

class ConversationClientMethods: NSObject, TWCONConversationClientApi {
    let TAG = "ConversationClientMethods"

    /// getConversation
    func getConversationConversationSidOrUniqueName(
        _ conversationSidOrUniqueName: String?,
        completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        self.debug("getConversation => conversationSidOrUniqueName: \(String(describing: conversationSidOrUniqueName))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSidOrUniqueName = conversationSidOrUniqueName else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'conversationSidOrUniqueName' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSidOrUniqueName,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getConversation => onSuccess")
                completion(Mapper.conversationToPigeon(conversation), nil)
            } else {
                self.debug("getConversation => onError: \(String(describing: result.error))")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation with sid or uniqueName '\(conversationSidOrUniqueName)'",
                        details: nil))
            }
        })
    }

    /// getMyConversations
    func getMyConversations(completion: @escaping ([TWCONConversationData]?, FlutterError?) -> Void) {
        self.debug("getMyConversations")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        let myConversations =  client.myConversations()
        let result = Mapper.conversationsList(myConversations)
        completion(result, nil)
    }

    /// getMyUser
    func getMyUser(completion: @escaping (TWCONUserData?, FlutterError?) -> Void) {
        self.debug("getMyUser")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        let myUser = client.user
        return completion(Mapper.userToPigeon(myUser), nil)
    }

    /// updateToken
    public func updateTokenToken(_ token: String?, completion: @escaping (FlutterError?) -> Void) {
        self.debug("updateToken")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let token = token else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'token' parameter",
                    details: nil))
        }

        client.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful {
                self.debug("updateToken => onSuccess")
                completion(nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("updateToken => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "TwilioException",
                        message: "\(result.error?.code)|Error updating token: \(errorMessage)",
                        details: nil))
            }
        } as TCHCompletion)
    }

    /// shutdown
    public func shutdownWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        self.debug("shutdown")
        SwiftTwilioConversationsPlugin.instance?.client?.shutdown()
        disposeListeners()
    }

    /// createConversation
    public func createConversationFriendlyName(
        _ friendlyName: String?,
        completion: @escaping (TWCONConversationData?, FlutterError?) -> Void) {
        self.debug("createConversation => friendlyName: \(String(describing: friendlyName))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let friendlyName = friendlyName else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'friendlyName' parameter",
                    details: nil))
        }

        let conversationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName
        ]

        client.createConversation(
            options: conversationOptions,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("createConversation => onSuccess")
                let conversationDict = Mapper.conversationToPigeon(conversation)
                completion(conversationDict, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("createConversation => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "TwilioException",
                        message: "\(result.error?.code)|Error creating conversation with "
                        + "friendlyName '\(friendlyName)': \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// registerForNotifications
    public func register(
        forNotificationTokenData tokenData: TWCONTokenData?,
        completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]) { (granted: Bool, _: Error?) in
                self.debug("register => User responded to permissions request: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        self.debug("register => Requesting APNS token")
                        SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "register"
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        completion(nil)
    }

    /// unregisterForNotifications
    public func unregister(
        forNotificationTokenData tokenData: TWCONTokenData?,
        completion: @escaping (FlutterError?) -> Void) {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                self.debug("unregister => Requesting APNS token")
                SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "deregister"
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        completion(nil)
    }

    private func disposeListeners() {
        SwiftTwilioConversationsPlugin.clientListener = nil
        SwiftTwilioConversationsPlugin.conversationListeners.removeAll()
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
