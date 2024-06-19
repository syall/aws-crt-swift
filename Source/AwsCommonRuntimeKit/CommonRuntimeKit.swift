import AwsCEventStream
import AwsCAuth
import AwsCMqtt
import LibNative

/**
 * Initializes the library.
 * `CommonRuntimeKit.initialize` must be called before using any other functionality.
 */
public struct CommonRuntimeKit {

    /// Initializes the library.
    /// Must be called before using any other functionality.
    public static func initialize() {
        aws_auth_library_init(allocator.rawValue)
        aws_event_stream_library_init(allocator.rawValue)
        aws_mqtt_library_init(allocator.rawValue)
        aws_register_error_info(&s_crt_swift_error_list);
    }

    /**
     * This is an optional cleanup function which will block until all the CRT resources have cleaned up.
     * Use this function only if you want to make sure that there are no memory leaks at the end of the application.
     * Warning: It will hang if you are still holding references to any CRT objects such as HostResolver.
     */
    public static func cleanUp() {
        aws_unregister_error_info(&s_crt_swift_error_list);
        aws_mqtt_library_clean_up()
        aws_event_stream_library_clean_up()
        aws_auth_library_clean_up()

    }

    private init() {}
}
