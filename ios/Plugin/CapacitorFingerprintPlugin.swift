import Foundation
import Capacitor
import FingerprintPro
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorFingerprintPlugin)
public class CapacitorFingerprintPlugin: CAPPlugin {
    private var fpjsClient: FingerprintClientProviding?

    @objc func load(_ call: CAPPluginCall) {
        let apiKey = call.getString("apiKey", "")
        fpjsClient = FingerprintProFactory.getInstance(apiKey)
        call.resolve()
    }

    @objc func getVisitorId(_ call: CAPPluginCall) async {
        let tags = call.getArray("tags")
        let linkedId = call.getString("linkedId")
        guard let fpjsClient = fpjsClient else {
            call.reject("Error: client is not initialized")
            return
        }
        let metadata = CapacitorFingerprintPlugin.prepareMetadata(linkedId, tags: tags)
        fpjsClient.getVisitorId(metadata) { result in
            switch result {
            case let .failure(error):
                let description = error.description
                call.reject("Error: ", description, error)
            case let .success(visitorId):
                // Prevent fraud cases in your apps with a unique
                // sticky and reliable ID provided by FingerprintJS Pro.
                call.resolve(["visitorId": visitorId])
            }
        }
    }
    @objc func getVisitorData(_ call: CAPPluginCall) {
        let tags = call.getArray("tags")
        let linkedId = call.getString("linkedId")
        guard let fpjsClient = fpjsClient else {
            call.reject("Error: client is not initialized")
            return
        }
        let metadata = CapacitorFingerprintPlugin.prepareMetadata(linkedId, tags: tags)
        fpjsClient.getVisitorIdResponse(metadata) { result in
            switch result {
            case let .failure(error):
                let description = error.description
                call.reject("Error: ", description, error)
            case let .success(visitorData):
                // Prevent fraud cases in your apps with a unique
                // sticky and reliable ID provided by FingerprintJS Pro.
                call.resolve(["visitorData": visitorData])
            }
        }
    }
    private static func parseRegion(_ passedRegion: String?, endpoint: String?) -> Region {
        var region: Region
        switch passedRegion {
        case "eu":
            region = .eu
        case "ap":
            region = .ap
        default:
            region = .global
        }

        if let endpointString = endpoint {
            region = .custom(domain: endpointString)
        }

        return region
    }

    private static func prepareMetadata(_ linkedId: String?, tags: JSArray?) -> Metadata {
        var metadata = Metadata(linkedId: linkedId)
        guard
            let tags = tags,
            let jsonTags = JSONTypeConvertor.convertObjectToJSONTypeConvertible(tags)
        else {
            return metadata
        }

        if let dict = jsonTags as? [String: JSONTypeConvertible] {
            dict.forEach { key, jsonType in
                metadata.setTag(jsonType, forKey: key)
            }
        } else {
            metadata.setTag(jsonTags, forKey: "tag")
        }

        return metadata
    }
}
