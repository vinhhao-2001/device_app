
import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

class MyModel: ObservableObject {
    static let shared = MyModel()
    let store = ManagedSettingsStore()
    
    private init() {}
    
    var selectionToDiscourage = FamilyActivitySelection() {
        willSet {
            let applications = newValue.applicationTokens
            let categories = newValue.categoryTokens
            let webCategories = newValue.webDomainTokens
            store.shield.applications = applications.isEmpty ? nil : applications
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
            store.shield.webDomains = webCategories
        }
    }
    
    func initiateMonitoring() {
        let schedule = DeviceActivitySchedule(intervalStart: DateComponents(hour: 0, minute: 0), intervalEnd: DateComponents(hour: 23, minute: 59), repeats: true, warningTime: nil)
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(.daily, during: schedule)
        }
        catch {
            print ("Could not start monitoring \(error)")
        }
        
        store.dateAndTime.requireAutomaticDateAndTime = true
        store.account.lockAccounts = true
        store.passcode.lockPasscode = true
        store.siri.denySiri = true
        store.appStore.denyInAppPurchases = true
        store.appStore.maximumRating = 1000
        store.appStore.requirePasswordForPurchases = true
        store.media.denyExplicitContent = true
        store.gameCenter.denyMultiplayerGaming = true
        store.media.denyMusicService = false
    }
    
    func settingMonitor(with options: [String: Any]){
        let schedule = DeviceActivitySchedule(intervalStart: DateComponents(hour: 0, minute: 0), intervalEnd: DateComponents(hour: 23, minute: 59), repeats: true, warningTime: nil)
        
        let center = DeviceActivityCenter()
        
        do{
            try center.startMonitoring(.daily, during: schedule)
        }catch{
            print("Không thể bắt đầu giám sát")
        }
        
        store.dateAndTime.requireAutomaticDateAndTime = options["requireAutomaticDateAndTime"] as? Bool ?? false
        
        store.account.lockAccounts = options["lockAccounts"] as? Bool ?? false
        
        store.passcode.lockPasscode = options["lockPasscode"] as? Bool ?? false
        
        store.siri.denySiri = options["denySiri"] as? Bool ?? false
        
        store.cellular.lockAppCellularData = false
        
        store.cellular.lockESIM = false
        
        store.appStore.denyInAppPurchases = options["denyInAppPurchases"] as? Bool ?? true
        store.appStore.maximumRating = options["maximumRating"] as? Int ?? 1000
        store.appStore.requirePasswordForPurchases = options["requirePasswordForPurchases"] as? Bool ?? true
        
        store.media.denyExplicitContent = options["denyExplicitContent"] as? Bool ?? true
        store.media.denyMusicService = options["denyMusicService"] as? Bool ?? false
        store.media.denyBookstoreErotica = false
        store.media.maximumMovieRating = 1000
        store.media.maximumTVShowRating = 1000
        
        store.gameCenter.denyMultiplayerGaming = options["denyMultiplayerGaming"] as? Bool ?? false
        store.gameCenter.denyAddingFriends = options["denyAddingFriends"] as? Bool ?? false
        
    }
}

extension DeviceActivityName {
    static let daily = Self("daily")
    static let weekly = Self("weekly")
}

