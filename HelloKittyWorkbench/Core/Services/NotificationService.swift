import Foundation
import UserNotifications

/// 本地通知服务
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授权")
            } else if let error = error {
                print("通知权限请求失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 设置饮水提醒
    func scheduleWaterReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "💧 该喝水啦"
        content.body = "记得补充水分哦，健康好习惯从喝水开始~"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 设置每日打卡提醒
    func scheduleCheckInReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "✅ 今日打卡提醒"
        content.body = "别忘了完成今天的打卡计划哦，坚持就是胜利~"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "checkInReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 设置心情记录提醒
    func scheduleMoodReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "😊 今天心情怎么样"
        content.body = "记录一下今天的心情吧，每一个瞬间都值得被记住~"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "moodReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 取消所有提醒
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// 取消特定提醒
    func cancelReminder(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
