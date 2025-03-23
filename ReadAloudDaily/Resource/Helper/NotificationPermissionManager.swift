//
//  NotificationPermissionManager.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/23/25.
//


import UIKit
import UserNotifications

struct NotificationPermissionManager {
    
    /// 알림 권한 상태를 확인하고, 거부된 경우 설정 화면으로 유도
    static func checkAndRequestPermission(from viewController: UIViewController) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // 아직 한 번도 요청 안 함 → 요청
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("🔔 알림 권한 허용됨")
                    } else {
                        print("❌ 알림 권한 거부됨 또는 오류: \(error?.localizedDescription ?? "")")
                    }
                }
                
            case .denied:
                // 이미 거부된 상태 → 설정화면 유도
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "알림 권한이 꺼져있어요",
                        message: "설정 > 알림에서 권한을 켜주세요.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    })
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    viewController.present(alert, animated: true)
                }
                
            case .authorized, .provisional, .ephemeral:
                // 이미 권한 허용됨 → 아무것도 안 해도 됨
                break
            @unknown default:
                break
            }
        }
    }
}

