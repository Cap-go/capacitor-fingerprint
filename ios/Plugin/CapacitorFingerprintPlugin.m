#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapacitorFingerprintPlugin, "CapacitorFingerprint",
           CAP_PLUGIN_METHOD(load, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getVisitorId, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getVisitorData, CAPPluginReturnPromise);
)
