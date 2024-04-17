///  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
///  SPDX-License-Identifier: Apache-2.0.

import Foundation
import AwsCMqtt
import AwsCIo

public class Mqtt5Client {
     private var rawValue: UnsafeMutablePointer<aws_mqtt5_client>?

    init(clientOptions options: MqttClientOptions) throws {

        let mqttShutdownCallbackCore = MqttShutdownCallbackCore(
            onPublishReceivedCallback: options.onPublishReceivedFn,
            onLifecycleEventStoppedCallback: options.onLifecycleEventStoppedFn,
            onLifecycleEventAttemptingConnect: options.onLifecycleEventAttemptingConnectFn,
            onLifecycleEventConnectionSuccess: options.onLifecycleEventConnectionSuccessFn,
            onLifecycleEventConnectionFailure: options.onLifecycleEventConnectionFailureFn,
            onLifecycleEventDisconnection: options.onLifecycleEventDisconnectionFn)

        guard let rawValue = (options.withCPointer(
            userData: mqttShutdownCallbackCore.shutdownCallbackUserData()) { optionsPointer in
                return aws_mqtt5_client_new(allocator.rawValue, optionsPointer)
        }) else {
            // failed to create client, release the callback core
            mqttShutdownCallbackCore.release()
            throw CommonRunTimeError.crtError(.makeFromLastError())
        }
        self.rawValue = rawValue
    }

    deinit {
        aws_mqtt5_client_release(rawValue)
    }

    public func start() throws {
        if rawValue != nil {
            let errorCode = aws_mqtt5_client_start(rawValue)

            if errorCode != 0 {
                throw CommonRunTimeError.crtError(CRTError(code: errorCode))
            }
        }
        // TODO Error should be thrown or client nil logged
    }

    public func stop(_ disconnectPacket: DisconnectPacket? = nil) throws {
        if rawValue != nil {
            var errorCode: Int32 = 0

            if let disconnectPacket = disconnectPacket {
                disconnectPacket.withCPointer { disconnectPointer in
                    errorCode = aws_mqtt5_client_stop(rawValue, disconnectPointer, nil)
                }
            } else {
                errorCode = aws_mqtt5_client_stop(rawValue, nil, nil)
            }

            if errorCode != 0 {
                throw CommonRunTimeError.crtError(CRTError(code: errorCode))
            }
        }
        // TODO Error should be thrown or client nil logged
    }

    public func close() {
        aws_mqtt5_client_release(rawValue)
        rawValue = nil
    }
}
