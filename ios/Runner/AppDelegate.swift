import Flutter
import UIKit
import SwiftUI
import FamilyControls
import CloudKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        let controller = window?.rootViewController as! FlutterViewController
        
        // Bật theo dõi pin
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        //  khai báo channel
        let initChannel = FlutterMethodChannel(name: "init_channel", binaryMessenger: controller.binaryMessenger)
        let methodChannel = FlutterMethodChannel(name: "screen_time", binaryMessenger: controller.binaryMessenger)
        let appLimitChannel = FlutterMethodChannel(name: "app_limit_channel", binaryMessenger: controller.binaryMessenger)
        let appMonitorChannel = FlutterMethodChannel(name: "app_monitor_channel", binaryMessenger: controller.binaryMessenger)
        initChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "init" {
                self.checkParentalControl()
                result(true)
            }
        }
        methodChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "blockApp":
                self.presentSwiftUIView(controller: controller)
            case "deviceInfo":
                self.getDeviceInfo(result: result)
            default:
                print("Tên channel bị lỗi")
            }
        }
        
        appLimitChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "appLimit" {
                // Mở giao diện giới hạn ứng dụng
                DispatchQueue.main.async {
                    let contentView = ContentView()
                    let host = UIHostingController(rootView: contentView)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(host, animated: true, completion: nil)
                    }
                }
                result("Opened app limit interface")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        appMonitorChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "appMonitor", let args = call.arguments as? [String: Any] {
                print("Cài đặt giám sát")
                MyModel.shared.settingMonitor(with: args)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func presentSwiftUIView(controller: FlutterViewController) {
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        controller.present(hostingController, animated: true, completion: nil)
    }
    
    private func checkParentalControl() {
        let center = AuthorizationCenter.shared
        Task {
            do {
                print("Kiểm tra tài khoản iCloud")
                let iCloudAvailable = try await self.checkICloudStatus()
                
                if iCloudAvailable {
                    print("Lấy trạng thái ủy quyền của ứng dụng")
                    try await center.requestAuthorization(for: FamilyControlsMember.child)
                    print("Yêu cầu quyền truy cập thành công")
                    
                    switch center.authorizationStatus {
                    case .notDetermined:
                        print("Chưa xác định")
                    case .denied:
                        print("Bị từ chối")
                    case .approved:
                        print("Đã được chấp nhận")
                        break
                    @unknown default:
                        break
                    }
                } else {
                    print("Thiết bị không có tài khoản iCloud hoặc chưa đăng nhập.")
                }
            } catch FamilyControlsError.invalidAccountType {
                print("Thiết bị phải đăng nhập tài khoản iCloud của trẻ")
            } catch {
                switch error{
                case FamilyControlsError.invalidAccountType:
                    print("Thiết bị phải đăng nhập tài khoản iCloud của trẻ")
                case FamilyControlsError.authorizationCanceled:
                    print("Chỉ cha mẹ hoặc người giám hộ mới được quản lý thiết bị")
                default:
                    print("Lỗi khi lấy quyền truy cập: \(error)")
                }
            }
        }
    }
    
    private func checkICloudStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let container = CKContainer.default()
            container.accountStatus { (accountStatus, error) in
                if let error = error {
                    print("Không lấy được trạng thái tài khoản: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    switch accountStatus {
                    case .available:
                        continuation.resume(returning: true)
                    case .noAccount:
                        print("Vui lòng đăng nhập tài khoản AppleID")
                        continuation.resume(returning: false)
                    case .restricted:
                        print("Tài khoản bị hạn chế")
                        continuation.resume(returning: false)
                    case .couldNotDetermine:
                        print("Không thể xác định trạng thái tài khoản")
                        continuation.resume(returning: false)
                    default:
                        print("Không lấy được trạng thái tài khoản")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    private func getDeviceInfo(result: @escaping FlutterResult) {
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        let deviceName = UIDevice.current.name
        let screenBrightness = Int(UIScreen.main.brightness * 100)
        let volume = AVAudioSession.sharedInstance().outputVolume
        
        // Tạo dictionary chứa thông tin
        let deviceInfo: [String: Any] = [
            "batteryLevel": "\(batteryLevel)%",
            "deviceName": deviceName,
            "screenBrightness": "\(screenBrightness)",
            "volume": "\(Int(volume * 100))"
        ]
        
        result(deviceInfo)
    }

}

//                    let contentView = ContentView()
//                    let host = UIHostingController(rootView: contentView)
//
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let rootViewController = windowScene.windows.first?.rootViewController {
//                        rootViewController.present(host, animated: true, completion: nil)
//                    }
