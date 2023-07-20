package ee.forgr.plugin.fingerprint;

import android.util.Pair;
import com.fingerprintjs.android.fpjs_pro.*;
import com.fingerprintjs.android.fpjs_pro.Error;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONException;
import org.json.JSONObject;

@CapacitorPlugin(name = "CapacitorFingerprint")
public class CapacitorFingerprintPlugin extends Plugin {

    private FingerprintJS fpjsClient;

    @PluginMethod
    public void load(PluginCall call) {
        String apiToken = call.getString("apiKey");
        String regionKey = call.getString("regionKey");
        String endpointUrl = call.getString("endpointUrl");
        Boolean extendedResponseFormat = call.getBoolean("extendedResponseFormat");
        String pluginVersion = call.getString("pluginVersion");
        Configuration.Region region = Configuration.Region.US;

        switch (regionKey) {
            case "eu":
                region = Configuration.Region.EU;
                break;
            case "us":
                region = Configuration.Region.US;
                break;
            case "ap":
                region = Configuration.Region.AP;
                break;
        }

        Configuration configuration = new Configuration(
            apiToken,
            region,
            endpointUrl != null ? endpointUrl : region.getEndpointUrl(),
            extendedResponseFormat
        );

        FingerprintJSFactory factory = new FingerprintJSFactory(getContext());
        fpjsClient = factory.createInstance(configuration);

        call.resolve();
    }

    private Map convertTagsToMap(JSArray tags) {
        Map tagsMap = new HashMap();
        for (int i = 0; i < tags.length(); i++) {
            try {
                JSONObject tag = tags.getJSONObject(i);
                tagsMap.put(tag.getString("key"), tag.getString("value"));
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return tagsMap;
    }

    @PluginMethod
    public void getVisitorId(PluginCall call) {
        Map tags = convertTagsToMap(call.getArray("tags", new JSArray()));
        String linkedId = call.getString("linkedId");
        fpjsClient.getVisitorId(
            tags,
            linkedId,
            result -> {
                JSObject ret = new JSObject();
                ret.put("visitorId", result.getVisitorId());
                call.resolve(ret);
                return null;
            },
            error -> {
                call.reject("Error: ", getErrorDescription(error));
                return null;
            }
        );
    }

    @PluginMethod
    public void getVisitorData(PluginCall call) {
        Map tags = convertTagsToMap(call.getArray("tags", new JSArray()));
        String linkedId = call.getString("linkedId");

        fpjsClient.getVisitorId(
            tags,
            linkedId,
            result -> {
                JSObject ret = new JSObject();
                ret.put("requestId", result.getRequestId());
                ret.put("confidenceScore", result.getConfidenceScore().getScore());
                var resultJsonString = result.getAsJson();
                // resultJsonString convert to object
                //                    try {
                ret.put("visitonData", resultJsonString);
                //                    } catch (JSONException e) {
                //                        throw new RuntimeException(e);
                //                    }
                call.resolve(ret);
                return null;
            },
            error -> {
                call.reject("Error: ", getErrorDescription(error));
                return null;
            }
        );
    }

    private String getErrorDescription(Error error) {
        String errorType = "UnknownError";

        // Determine error type based on instance
        // e.g., if (error instanceof ApiKeyRequired) -> errorType = "ApiKeyRequired";

        return errorType + ":" + error.getDescription();
    }
}
