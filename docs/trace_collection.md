# iOS Trace Collection

<div class="alert alert-info">The iOS Trace collection is in public beta. If you have any questions, contact our [support team][11].</div>

Send [traces][1] to Datadog from your iOS applications with [Datadog's `dd-sdk-ios` client-side tracing library][2] and leverage the following features:

* Create custom [spans][3] for various operations in your app.
* Send logs for each span individually.
* Use default and add custom attributes to each span.
* Leverage optimized network usage with automatic bulk posts.

## Setup

1. Declare the library as a dependency depending on your package manager:

    {{< tabs >}}
    {{% tab "CocoaPods" %}}

You can use [CocoaPods][4] to install `dd-sdk-ios`:
```
pod 'DatadogSDK'
```

[4]: https://cocoapods.org/

    {{% /tab %}}
    {{% tab "Swift Package Manager (SPM)" %}}

To integrate using Apple's Swift Package Manager, add the following as a dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/Datadog/dd-sdk-ios.git", .upToNextMajor(from: "1.0.0"))
```

    {{% /tab %}}
    {{% tab "Carthage" %}}

You can use [Carthage][5] to install `dd-sdk-ios`:
```
github "DataDog/dd-sdk-ios"
```

[5]: https://github.com/Carthage/Carthage

    {{% /tab %}}
    {{< /tabs >}}

2. Initialize the library with your application context and your [Datadog client token][6]. For security reasons, you must use a client token: you cannot use [Datadog API keys][7] to configure the `dd-sdk-ios` library as they would be exposed client-side in the iOS application IPA byte code. For more information about setting up a client token, see the [client token documentation][6].

    {{< tabs >}}
    {{% tab "US" %}}

```swift
Datadog.initialize(
    appContext: .init(),
    configuration: Datadog.Configuration
        .builderUsing(clientToken: "<client_token>", environment: "<environment_name>")
        .set(serviceName: "app-name")
        .build()
)
```

    {{% /tab %}}
    {{% tab "EU" %}}

```swift
Datadog.initialize(
    appContext: .init(),
    configuration: Datadog.Configuration
        .builderUsing(clientToken: "<client_token>", environment: "<environment_name>")
        .set(serviceName: "app-name")
        .set(tracesEndpoint: .eu)
        .build()
)
```

    {{% /tab %}}
    {{< /tabs >}}

     When writing your application, you can enable development logs. All internal messages in the SDK with a priority equal to or higher than the provided level are then logged to console logs.

    ```swift
    Datadog.verbosityLevel = .debug
    ```

3. Datadog tracer implements the [Open Tracing standard][8]. Configure and register the `DDTracer` globally as Open Tracing `Global.sharedTracer`. You only need to do it once, usually in your `AppDelegate` code:

    ```swift
    import Datadog
    import OpenTracing

    Global.sharedTracer = DDTracer.initialize(
        configuration: DDTracer.Configuration(
            sendNetworkInfo: true
        )
    )
    ```

4. Instrument your code using the following methods:

    ```swift
    import OpenTracing

    let span = Global.sharedTracer.startSpan(operationName: "<span_name>")
    // do something you want to measure ...
    // ... then, when the operation is finished:
    span.finish()
    ```

5. (Optional) - Set child-parent relationship between your spans:

    ```swift
    let responseDecodingSpan = Global.sharedTracer.startSpan(
        operationName: "response decoding",
        childOf: networkRequestSpan.context // make it a child of `networkRequestSpan`
    )
    // ... decode HTTP response data ...
    responseDecodingSpan.finish()
    ```

6. (Optional) - Provide additional tags alongside your span:

    ```swift
    span.setTag(key: "http.url", value: url)
    ```

7. (Optional) Attach an error to a span - you can do so by logging the error information using the [standard Open Tracing log fields][9]:

    ```swift
    span.log(
        fields: [
            "event": "error",
            "error.kind": "I/O Exception",
            "message": "File not found",
            "stack": "FileReader.swift:42",
        ]
    )
    ```

8. (Optional) To distribute traces between your environments, for example frontend - backend, inject tracer context in the client request:

    ```swift
    import OpenTracing
    import Datadog

    var request: URLRequest = ... // the request to your API

    let span = Global.sharedTracer.startSpan(operationName: "network request")

    let headersWritter = DDHTTPHeadersWriter()
    Global.sharedTracer.inject(spanContext: span.context, writer: headersWritter)

    for (headerField, value) in headersWritter.tracePropagationHTTPHeaders {
        request.addValue(value, forHTTPHeaderField: headerField)
    }
    ```
    This will set additional tracing headers on your request, so that your backend can extract it and continue distributed tracing. If your backend is also instrumented with [Datadog APM & Distributed Tracing][10] you will see the entire front-to-back trace in Datadog dashboard.


## Batch collection

All the spans are first stored on the local device in batches. Each batch follows the intake specification. They are sent periodically if network is available, and the battery is high enough to ensure the Datadog SDK does not impact the end user's experience. If the network is not available while your application is in the foreground, or if an upload of data fails, the batch is kept until it can be sent successfully.

This means that even if users open your application while being offline, no data will be lost.

The data on disk will automatically be discarded if it gets too old to ensure the SDK doesn't use too much disk space.

## Further Reading

{{< partial name="whats-next/whats-next.html" >}}

[1]: https://docs.datadoghq.com/tracing/visualization/#trace
[2]: https://github.com/DataDog/dd-sdk-ios
[3]: https://docs.datadoghq.com/tracing/visualization/#spans
[6]: https://docs.datadoghq.com/account_management/api-app-keys/#client-tokens
[7]: https://docs.datadoghq.com/account_management/api-app-keys/#api-keys
[8]: https://opentracing.io
[9]: https://github.com/opentracing/specification/blob/master/semantic_conventions.md#log-fields-table
[10]: https://docs.datadoghq.com/tracing/
[11]: /help/