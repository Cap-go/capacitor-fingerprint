package ee.forgr.plugin.fingerprint;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.fingerprintjs.android.fpjs_pro.Configuration;
import com.fingerprintjs.android.fpjs_pro.FingerprintJS;
import com.fingerprintjs.android.fpjs_pro.FingerprintJSFactory;

@CapacitorPlugin(name = "CapacitorFingerprint")
public class CapacitorFingerprintPlugin extends Plugin {
    FingerprintJS fpjsClient;

    @PluginMethod
    public void load(PluginCall call) {
        String apiKey = call.getString("apiKey");

        FingerprintJSFactory factory = new FingerprintJSFactory(this.getApplicationContext());
        Configuration configuration = new Configuration(apiKey);

        fpjsClient = factory.createInstance(
            configuration
        );

        JSObject ret = new JSObject();
        call.resolve(ret);
    }
    // getVisitorId
    @PluginMethod
    public void getVisitorId(PluginCall call) {
        String tags = call.getArray("tags");
        String linkedId = call.getString("linkedId");
        fpjsClient?.getVisitorId(tags?.toHashMap() ?: emptyMap(),
            linkedId ?: "",
            { result -> {
                JSObject ret = new JSObject();
                ret.put("visitorId", result.getVisitorId());
                call.resolve(ret);
                } 
            },
            { error -> call.reject("Error: " + getErrorDescription(error))
        })

    }

    //getVisitorData
    @PluginMethod
    public void getVisitorData(PluginCall call) {
        String tags = call.getArray("tags");
        String linkedId = call.getString("linkedId");

        // JSObject ret = new JSObject();
        // ret.put("value", implementation.echo(value));
        // call.resolve(ret);
        try {
            fpjsClient?.getVisitorId(tags?.toHashMap() ?: emptyMap(),
                linkedId ?: "",
                { result -> {
                        JSObject ret = new JSObject();
                        ret.put("visitorData", call.resolve(Arguments.fromList(listOf(result.requestId, result.confidenceScore.score, result.asJson)));
                        call.resolve(ret);
                    } 
                },
                { error -> call.reject("Error: " + getErrorDescription(error))
            })
        } catch (e: Exception) {
            call.reject("Error: " + e)
        }
    }

    private fun getErrorDescription(error: Error): String {
        val errorType = when(error) {
            is ApiKeyRequired -> "ApiKeyRequired"
            is ApiKeyNotFound ->  "ApiKeyNotFound"
            is ApiKeyExpired -> "ApiKeyExpired"
            is RequestCannotBeParsed -> "RequestCannotBeParsed"
            is Failed -> "Failed"
            is RequestTimeout -> "RequestTimeout"
            is TooManyRequest -> "TooManyRequest"
            is OriginNotAvailable -> "OriginNotAvailable"
            is HeaderRestricted -> "HeaderRestricted"
            is NotAvailableForCrawlBots -> "NotAvailableForCrawlBots"
            is NotAvailableWithoutUA -> "NotAvailableWithoutUA"
            is WrongRegion -> "WrongRegion"
            is SubscriptionNotActive -> "SubscriptionNotActive"
            is UnsupportedVersion -> "UnsupportedVersion"
            is InstallationMethodRestricted -> "InstallationMethodRestricted"
            is ResponseCannotBeParsed -> "ResponseCannotBeParsed"
            is NetworkError -> "NetworkError"
            is UnknownError -> "UnknownError"
            else -> "UnknownError"
        }
        return errorType + ":" + error.description
    }
}
