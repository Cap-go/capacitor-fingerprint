import Foundation
import Capacitor
import FingerprintPro
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorFingerprintPlugin)
public class CapacitorFingerprintPlugin: CAPPlugin {
    let client;

    @objc func load(_ call: CAPPluginCall) {
        let apiKey = call.getString("apiKey", "")
        client = FingerprintProFactory.getInstance(apiKey)
        call.resolve()
    }

    @objc func getVisitorId(_ call: CAPPluginCall) {
        let value = call.getString("value", "")
        do {
            let visitorId = try await client.getVisitorId()
            print(visitorId)
                    call.resolve([
            "visitorId": visitorId
        ])
        } catch {
            // process error
            call.reject("Error" + error.localizedDescription)
        }
    }
    @objc func getVisitorData(_ call: CAPPluginCall) {
        do {
            let metadata = CapacitorFingerprintPlugin.prepareMetadata(linkedId, tags: tags)
            client?.getVisitorIdResponse(metadata) { result in
                switch result {
                case let .failure(error):
                    let description = error.reactDescription
                    call.reject("Error: \(description), \(error)")
                case let .success(visitorDataResponse):
                    let tuple = [
                        visitorDataResponse.requestId,
                        visitorDataResponse.confidence,
                        visitorDataResponse.asJSON()
                    ] as [Any]
                    call.resolve(tuple)
                }
            }
        } catch {
            // process error
            call.reject("Error" + error.localizedDescription)
        }
        call.resolve([
            "value": implementation.echo(value)
        ])
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

    private static func prepareMetadata(_ linkedId: String?, tags: Any?) -> Metadata {
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
