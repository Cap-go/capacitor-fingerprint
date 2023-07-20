import Foundation
import Capacitor
import FingerprintPro
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorFingerprintPlugin)
public class CapacitorFingerprintPlugin: CAPPlugin {
    let client

    @objc func load(_ call: CAPPluginCall) {
        let apiKey = call.getString("apiKey", "")
        client = FingerprintProFactory.getInstance(apiKey)
        call.resolve()
    }

    @objc func getVisitorId(_ call: CAPPluginCall) {
        let tags = call.getArray("tags")
        let linkedId = call.getString("linkedId")
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
        let tags = call.getArray("tags")
        let linkedId = call.getString("linkedId")
        do {
            let visitorData = try await client.getVisitorData()
            print(visitorData)
            call.resolve([
                "visitorData": visitorData
            ])
        } catch {
            // process error
            call.reject("Error" + error.localizedDescription)
        }
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
}
