/// Localized text resolved in the shared resource bundle across module boundaries.
import Foundation

public enum SharedStrings {
    public nonisolated static func resource(_ key: String.LocalizationValue, comment: StaticString? = nil) -> LocalizedStringResource {
        LocalizedStringResource(key, bundle: .atURL(SharedResources.bundle.bundleURL), comment: comment)
    }

    public nonisolated static var bird: LocalizedStringResource {
        LocalizedStringResource("Bird", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var cat: LocalizedStringResource {
        LocalizedStringResource("Cat", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var change: LocalizedStringResource {
        LocalizedStringResource("Change", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var dog: LocalizedStringResource {
        LocalizedStringResource("Dog", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eveningSelected: LocalizedStringResource {
        LocalizedStringResource("Evening Selected", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var fish: LocalizedStringResource {
        LocalizedStringResource("Fish", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var morningSelected: LocalizedStringResource {
        LocalizedStringResource("Morning Selected", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var other: LocalizedStringResource {
        LocalizedStringResource("Other", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var save: LocalizedStringResource {
        LocalizedStringResource("Save", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addText: LocalizedStringResource {
        LocalizedStringResource("addText", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addAnimalAccessibleLabel: LocalizedStringResource {
        LocalizedStringResource("add_animal_accessible_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addAnimalButton: LocalizedStringResource {
        LocalizedStringResource("add_animal_button", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventAccessibleTitle: LocalizedStringResource {
        LocalizedStringResource("add_event_accessible_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventDate: LocalizedStringResource {
        LocalizedStringResource("add_event_date", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventEnd: LocalizedStringResource {
        LocalizedStringResource("add_event_end", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventInfo: LocalizedStringResource {
        LocalizedStringResource("add_event_info", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventName: LocalizedStringResource {
        LocalizedStringResource("add_event_name", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventNote: LocalizedStringResource {
        LocalizedStringResource("add_event_note", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventSave: LocalizedStringResource {
        LocalizedStringResource("add_event_save", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventStart: LocalizedStringResource {
        LocalizedStringResource("add_event_start", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventTime: LocalizedStringResource {
        LocalizedStringResource("add_event_time", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addEventTitle: LocalizedStringResource {
        LocalizedStringResource("add_event_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var allDayTitle: LocalizedStringResource {
        LocalizedStringResource("all_day_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var appSettings: LocalizedStringResource {
        LocalizedStringResource("app_settings", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var appleMaps: LocalizedStringResource {
        LocalizedStringResource("apple_maps", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var birthdayAskLabel: LocalizedStringResource {
        LocalizedStringResource("birthday_ask_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var birthdayTitle: LocalizedStringResource {
        LocalizedStringResource("birthday_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var buyCoffeeTitle: LocalizedStringResource {
        LocalizedStringResource("buy_coffee_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var cancelTitle: LocalizedStringResource {
        LocalizedStringResource("cancelTitle", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var cantFetchStatus: LocalizedStringResource {
        LocalizedStringResource("cant_fetch_status", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var cloudUnavailable: LocalizedStringResource {
        LocalizedStringResource("cloud_unavailable", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var `continue`: LocalizedStringResource {
        LocalizedStringResource("continue", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var date: LocalizedStringResource {
        LocalizedStringResource("date", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var dateSelectLabel: LocalizedStringResource {
        LocalizedStringResource("date_select_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var defaultPhotoLabel: LocalizedStringResource {
        LocalizedStringResource("default_photo_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var defaultVetText: LocalizedStringResource {
        LocalizedStringResource("default_vet_text", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsClear: LocalizedStringResource {
        LocalizedStringResource("donate_us_clear", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsClearedSuccessfull: LocalizedStringResource {
        LocalizedStringResource("donate_us_cleared_successfull", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsComment: LocalizedStringResource {
        LocalizedStringResource("donate_us_comment", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsContext: LocalizedStringResource {
        LocalizedStringResource("donate_us_context", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsDonated: LocalizedStringResource {
        LocalizedStringResource("donate_us_donated", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var donateUsTitle: LocalizedStringResource {
        LocalizedStringResource("donate_us_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventNoTitle: LocalizedStringResource {
        LocalizedStringResource("event_no_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventTabTitle: LocalizedStringResource {
        LocalizedStringResource("event_tab_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventTitle: LocalizedStringResource {
        LocalizedStringResource("event_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedContent: LocalizedStringResource {
        LocalizedStringResource("feed_content", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedHistoryTitle: LocalizedStringResource {
        LocalizedStringResource("feed_history_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedSelectionBoth: LocalizedStringResource {
        LocalizedStringResource("feed_selection_both", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedSelectionEvening: LocalizedStringResource {
        LocalizedStringResource("feed_selection_evening", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedSelectionMorning: LocalizedStringResource {
        LocalizedStringResource("feed_selection_morning", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedTimeTitle: LocalizedStringResource {
        LocalizedStringResource("feed_time_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var findVetOpen: LocalizedStringResource {
        LocalizedStringResource("find_vet_open", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var findVetSimulationError: LocalizedStringResource {
        LocalizedStringResource("find_vet_simulation_error", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var findVetTitle: LocalizedStringResource {
        LocalizedStringResource("find_vet_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var googleMaps: LocalizedStringResource {
        LocalizedStringResource("google_maps", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var hello: LocalizedStringResource {
        LocalizedStringResource("hello", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var homeTabTitle: LocalizedStringResource {
        LocalizedStringResource("home_tab_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var lastFeedTitle: LocalizedStringResource {
        LocalizedStringResource("last_feed_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var locationAlertChange: LocalizedStringResource {
        LocalizedStringResource("location_alert_change", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var locationAlertContext: LocalizedStringResource {
        LocalizedStringResource("location_alert_context", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var locationAlertTitle: LocalizedStringResource {
        LocalizedStringResource("location_alert_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var locationSearchTitle: LocalizedStringResource {
        LocalizedStringResource("location_search_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var managePetTitle: LocalizedStringResource {
        LocalizedStringResource("manage_pet_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var name: LocalizedStringResource {
        LocalizedStringResource("name", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var nameError: LocalizedStringResource {
        LocalizedStringResource("name_error", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var noAccount: LocalizedStringResource {
        LocalizedStringResource("no_account", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var noFeedContent: LocalizedStringResource {
        LocalizedStringResource("no_feed_content", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var noFeedTodayContent: LocalizedStringResource {
        LocalizedStringResource("no_feed_today_content", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var noVaccineTitle: LocalizedStringResource {
        LocalizedStringResource("no_vaccine_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func notification(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notification %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func notificationBirthdayContent(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("notification_birthday_content %@", defaultValue: "\(arg1)", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func notificationContent(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("notification_content %@", defaultValue: "\(arg1)", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationTitle: LocalizedStringResource {
        LocalizedStringResource("notification_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationTo: LocalizedStringResource {
        LocalizedStringResource("notification_to", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func notifications(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notifications %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationsManageTitle: LocalizedStringResource {
        LocalizedStringResource("notifications_manage_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationsTitle: LocalizedStringResource {
        LocalizedStringResource("notifications_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var openSettings: LocalizedStringResource {
        LocalizedStringResource("open_settings", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var paymentCant: LocalizedStringResource {
        LocalizedStringResource("payment_cant", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petNameTitle: LocalizedStringResource {
        LocalizedStringResource("pet_name_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func petNameTitle(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("pet_name_title %@", defaultValue: "\(arg1)", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petNoPet: LocalizedStringResource {
        LocalizedStringResource("pet_no_pet", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petSelect: LocalizedStringResource {
        LocalizedStringResource("pet_select", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var photoSetLabel: LocalizedStringResource {
        LocalizedStringResource("photo_set_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var photoTitle: LocalizedStringResource {
        LocalizedStringResource("photo_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var photoUploadDetailTitle: LocalizedStringResource {
        LocalizedStringResource("photo_upload_detail_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var previousTitle: LocalizedStringResource {
        LocalizedStringResource("previous_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var privacyPolicyContent: LocalizedStringResource {
        LocalizedStringResource("privacy_policy_content", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var privacyPolicyTitle: LocalizedStringResource {
        LocalizedStringResource("privacy_policy_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var refresh: LocalizedStringResource {
        LocalizedStringResource("refresh", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var removeAll: LocalizedStringResource {
        LocalizedStringResource("remove_all", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var restrictedAccount: LocalizedStringResource {
        LocalizedStringResource("restricted_account", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var selectDate: LocalizedStringResource {
        LocalizedStringResource("select_date", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var settingsTabTitle: LocalizedStringResource {
        LocalizedStringResource("settings_tab_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var settingsTintColor: LocalizedStringResource {
        LocalizedStringResource("settings_tint_color", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var settingsTitle: LocalizedStringResource {
        LocalizedStringResource("settings_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var setupName: LocalizedStringResource {
        LocalizedStringResource("setup_name", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var setupTitle: LocalizedStringResource {
        LocalizedStringResource("setup_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var startNameLabel: LocalizedStringResource {
        LocalizedStringResource("start_name_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var tapToChangeText: LocalizedStringResource {
        LocalizedStringResource("tap_to_change_text", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var today: LocalizedStringResource {
        LocalizedStringResource("today", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var upcomingTitle: LocalizedStringResource {
        LocalizedStringResource("upcoming_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var vaccineHistoryTitle: LocalizedStringResource {
        LocalizedStringResource("vaccine_history_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var welcomeAddPet: LocalizedStringResource {
        LocalizedStringResource("welcome_add_pet", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var welcomeContext: LocalizedStringResource {
        LocalizedStringResource("welcome_context", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var welcomeRestore: LocalizedStringResource {
        LocalizedStringResource("welcome_restore", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var welcomeTitle: LocalizedStringResource {
        LocalizedStringResource("welcome_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var yandexNavi: LocalizedStringResource {
        LocalizedStringResource("yandex_navi", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var _02FeedGiven: LocalizedStringResource {
        LocalizedStringResource("0/2 feed given", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var _12FeedGiven: LocalizedStringResource {
        LocalizedStringResource("1/2 feed given", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addPet: LocalizedStringResource {
        LocalizedStringResource("Add Pet", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var all: LocalizedStringResource {
        LocalizedStringResource("All", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var allNotifications: LocalizedStringResource {
        LocalizedStringResource("All Notifications", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var allFeedsAreGiven: LocalizedStringResource {
        LocalizedStringResource("All feeds are given", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var allNeedsComplete: LocalizedStringResource {
        LocalizedStringResource("All needs complete", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var back: LocalizedStringResource {
        LocalizedStringResource("Back", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var chooseFriend: LocalizedStringResource {
        LocalizedStringResource("Choose Friend", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var createDefaultNotificationsForYourPet: LocalizedStringResource {
        LocalizedStringResource("Create default notifications for your pet.", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var done: LocalizedStringResource {
        LocalizedStringResource("Done", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var edit: LocalizedStringResource {
        LocalizedStringResource("Edit", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eveningFeed: LocalizedStringResource {
        LocalizedStringResource("Evening feed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var history: LocalizedStringResource {
        LocalizedStringResource("History", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var morningFeed: LocalizedStringResource {
        LocalizedStringResource("Morning feed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var next: LocalizedStringResource {
        LocalizedStringResource("Next", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var ok: LocalizedStringResource {
        LocalizedStringResource("OK", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petBreedOptional: LocalizedStringResource {
        LocalizedStringResource("Pet Breed (Optional)", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petExists: LocalizedStringResource {
        LocalizedStringResource("Pet Exists", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var remove: LocalizedStringResource {
        LocalizedStringResource("Remove", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var retry: LocalizedStringResource {
        LocalizedStringResource("Retry", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var reviewFeedingRecords: LocalizedStringResource {
        LocalizedStringResource("Review feeding records", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var reviewVaccineRecords: LocalizedStringResource {
        LocalizedStringResource("Review vaccine records", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var saveFailed: LocalizedStringResource {
        LocalizedStringResource("Save Failed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var saveSuccessful: LocalizedStringResource {
        LocalizedStringResource("Save Successful", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static func selectedCalendar(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("Selected Calendar: %@", defaultValue: "\(arg1)", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var todaysCare: LocalizedStringResource {
        LocalizedStringResource("Today's care", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var add: LocalizedStringResource {
        LocalizedStringResource("add", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var addVaccine: LocalizedStringResource {
        LocalizedStringResource("addVaccine", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var birthdayInformation: LocalizedStringResource {
        LocalizedStringResource("birthday_information", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var debugMenuTitle: LocalizedStringResource {
        LocalizedStringResource("debug_menu_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var errorTitle: LocalizedStringResource {
        LocalizedStringResource("errorTitle", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventErrorTitle: LocalizedStringResource {
        LocalizedStringResource("event_error_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventNotAllowed: LocalizedStringResource {
        LocalizedStringResource("event_not_allowed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var eventWrongAllowence: LocalizedStringResource {
        LocalizedStringResource("event_wrong_allowence", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var feedsTitle: LocalizedStringResource {
        LocalizedStringResource("feeds_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var findVetErrorTitle: LocalizedStringResource {
        LocalizedStringResource("find_vet_error_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var licenseTitle: LocalizedStringResource {
        LocalizedStringResource("license_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var licenseViewLabel: LocalizedStringResource {
        LocalizedStringResource("license_view_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var mapOpenIn: LocalizedStringResource {
        LocalizedStringResource("map_open_in", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var nameExistError: LocalizedStringResource {
        LocalizedStringResource("name_exist_error", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var nextNotificationDate: LocalizedStringResource {
        LocalizedStringResource("next_notification_date", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationBirthdayUpdateFailed: LocalizedStringResource {
        LocalizedStringResource("notificationBirthdayUpdateFailed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var notificationDailyUpdateFailed: LocalizedStringResource {
        LocalizedStringResource("notificationDailyUpdateFailed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petSaveFailed: LocalizedStringResource {
        LocalizedStringResource("petSaveFailed", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petAddPet: LocalizedStringResource {
        LocalizedStringResource("pet_add_pet", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petBreedAdd: LocalizedStringResource {
        LocalizedStringResource("pet_breed_add", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petBreedTitle: LocalizedStringResource {
        LocalizedStringResource("pet_breed_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petFact: LocalizedStringResource {
        LocalizedStringResource("pet_fact", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var petKindText: LocalizedStringResource {
        LocalizedStringResource("pet_kind_text", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var removeUserdefaults: LocalizedStringResource {
        LocalizedStringResource("remove_userdefaults", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var unknownError: LocalizedStringResource {
        LocalizedStringResource("unknownError", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var vaccineDateLabel: LocalizedStringResource {
        LocalizedStringResource("vaccine_date_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var vaccineTitleLabel: LocalizedStringResource {
        LocalizedStringResource("vaccine_title_label", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var vaccinesTitle: LocalizedStringResource {
        LocalizedStringResource("vaccines_title", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
    public nonisolated static var welcomeGoButton: LocalizedStringResource {
        LocalizedStringResource("welcome_go_button", table: "Localizable", bundle: .atURL(SharedResources.bundle.bundleURL))
    }
}
