import Flutter
import TwilioConversationsClient

class PluginMethods: NSObject, TWCONPluginApi {
    let TAG = "PluginMethods"

    func debugEnableNative(
        _ enableNative: NSNumber,
        enableSdk: NSNumber,
        error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        SwiftTwilioConversationsPlugin.nativeDebug = enableNative.boolValue
        if enableSdk.boolValue {
            TwilioConversationsClient.setLogLevel(TCHLogLevel.debug)
        } else {
            TwilioConversationsClient.setLogLevel(TCHLogLevel.warning)
        }
    }

    // Naming a by product of pigeon generation. This creates a conversations client, not a JWT token.
    func createJwtToken(
        _ jwtToken: String?,
        properties: TWCONPropertiesData?,
        completion: @escaping (TWCONConversationClientData?, FlutterError?) -> Void) {
        guard let jwtToken = jwtToken else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'token' parameter",
                    details: nil))
        }

        guard let properties = properties else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'properties' parameter",
                    details: nil))
        }
        debug("create => jwtToken: \(jwtToken)")

        let clientProperties = TwilioConversationsClientProperties()
        clientProperties.region = properties.region ?? "us1"

        SwiftTwilioConversationsPlugin.clientListener = ClientListener()

        TwilioConversationsClient.conversationsClient(
            withToken: jwtToken,
            properties: clientProperties,
            delegate: SwiftTwilioConversationsPlugin.clientListener,
            completion: { (result: TCHResult, conversationsClient: TwilioConversationsClient?) in
                if result.isSuccessful {
                    let myIdentity = conversationsClient?.user?.identity ?? "unknown"
                    self.debug("create => onSuccess - myIdentity: '\(myIdentity)'")
                    conversationsClient?.delegate = SwiftTwilioConversationsPlugin.clientListener
                    SwiftTwilioConversationsPlugin.instance?.client = conversationsClient
                    let clientData = Mapper.conversationsClientToPigeon(conversationsClient)
                    completion(clientData, nil)
                } else {
                    self.debug("create => onError: \(String(describing: result.error))")
                    completion(
                        nil,
                        FlutterError(
                            code: "TwilioException",
                            message: "\(result.error?.code)|Error creating client, Error: "
                            + "\(result.error.debugDescription)",
                            details: nil))
                }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
