// iOS implementation for a custom Capacitor Pedometer plugin using CMPedometer
// File: ios/Plugin/PedometerPlugin.swift

import Foundation
import Capacitor
import CoreMotion

@objc(PedometerPlugin)
public class PedometerPlugin: CAPPlugin {
    private let pedometer = CMPedometer()
    private var hasListeners = false

    @objc func checkPermission(_ call: CAPPluginCall) {
        if CMPedometer.authorizationStatus() == .authorized {
            call.resolve(["granted": true])
        } else {
            call.resolve(["granted": false])
        }
    }

    @objc func start(_ call: CAPPluginCall) {
        if CMPedometer.isStepCountingAvailable() {
            let now = Date()
            pedometer.startUpdates(from: now) { data, error in
                guard error == nil, let data = data else {
                    self.notifyListeners("stepUpdate", data: ["error": error?.localizedDescription ?? "Unknown error"])
                    return
                }
                if self.hasListeners {
                    self.notifyListeners("stepUpdate", data: [
                        "steps": data.numberOfSteps
                    ])
                }
            }
            call.resolve()
        } else {
            call.reject("Step counting not available")
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        pedometer.stopUpdates()
        call.resolve()
    }

    @objc func getStepsBetween(_ call: CAPPluginCall) {
        guard let start = call.getDouble("start"),
              let end = call.getDouble("end") else {
            call.reject("Missing start or end timestamp")
            return
        }
        let startDate = Date(timeIntervalSince1970: start / 1000)
        let endDate = Date(timeIntervalSince1970: end / 1000)

        pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
            if let error = error {
                call.reject(error.localizedDescription)
                return
            }
            if let data = data {
                call.resolve([
                    "steps": data.numberOfSteps
                ])
            }
        }
    }

    // Listener control
    @objc override public func addListener(_ call: CAPPluginCall) {
        hasListeners = true
        call.resolve()
    }

    @objc override public func removeListeners(_ call: CAPPluginCall) {
        hasListeners = false
        call.resolve()
    }
}
