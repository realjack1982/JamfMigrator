//
//  SourceDestVC.swift
//  jamf-migrator
//
//  Created by lnh on 12/9/16.
//  Copyright © 2016 jamf. All rights reserved.
//

import AppKit
import Cocoa
import Foundation

class SourceDestVC: NSViewController, URLSessionDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    let userDefaults = UserDefaults.standard
    
    // Main Window
//    @IBOutlet var migrator_window: NSView!
    
    @IBOutlet weak var hideCreds_button: NSButton!
    @IBAction func hideCreds_action(_ sender: Any) {
        userDefaults.set("\(hideCreds_button.state.rawValue)", forKey: "hideCreds")
        setWindowSize(setting: hideCreds_button.state.rawValue)
    }
    func setWindowSize(setting: Int) {
        if setting == 0 {
            preferredContentSize = CGSize(width: 848, height: 55)
            hideCreds_button.toolTip = "show"
        } else {
            preferredContentSize = CGSize(width: 848, height: 120)
            hideCreds_button.toolTip = "hide"
        }
    }
    @IBOutlet weak var setDestSite_button: NSPopUpButton!
    @IBOutlet weak var sitesSpinner_ProgressIndicator: NSProgressIndicator!
    
    // Import file variables
    @IBOutlet weak var importFiles_button: NSButton!
    @IBOutlet weak var browseFiles_button: NSButton!
    var exportedFilesUrl = URL(string: "")
    var xportFolderPath: URL? {
        didSet {
            do {
                let bookmark = try xportFolderPath?.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                self.userDefaults.set(bookmark, forKey: "bookmark")
            } catch let error as NSError {
                print("[SourceDestVC] Set Bookmark Fails: \(error.description)")
            }
        }
    }
    
    var availableFilesToMigDict = [String:[String]]()   // something like xmlID, xmlName
    var displayNameToFilename   = [String: String]()
        
    // determine if we're using dark mode
    var isDarkMode: Bool {
        let mode = userDefaults.string(forKey: "AppleInterfaceStyle")
        return mode == "Dark"
    }
    
    // keychain access
    let Creds2           = Credentials2()
    var validCreds       = true     // used to deterine if keychain has valid credentials
    var storedSourceUser = ""       // source user account stored in the keychain
    var storedSourcePwd  = ""       // source user account password stored in the keychain
    var storedDestUser   = ""       // destination user account stored in the keychain
    var storedDestPwd    = ""       // destination user account password stored in the keychain
    @IBOutlet weak var storeCredentials_button: NSButton!
//    var storeCredentials = 0
    @IBAction func storeCredentials(_ sender: Any) {
//        storeCredentials = storeCredentials_button.state.rawValue
        JamfProServer.storeCreds = storeCredentials_button.state.rawValue
    }
     
    
    @IBOutlet weak var sourceServerList_button: NSPopUpButton!
    @IBOutlet weak var destServerList_button: NSPopUpButton!
    @IBOutlet weak var siteMigrate_button: NSButton!
    @IBOutlet weak var availableSites_button: NSPopUpButtonCell!
    
    var itemToSite      = false
    var destinationSite = ""
    
    @IBOutlet weak var destinationLabel_TextField: NSTextField!
//    @IBOutlet weak var destinationMethod_TextField: NSTextField!
    
//    @IBOutlet weak var quit_button: NSButton!
//    @IBOutlet weak var go_button: NSButton!
//    @IBOutlet weak var stop_button: NSButton!
    
    // Migration mode/platform tabs/var
//    @IBOutlet weak var bulk_tabViewItem: NSTabViewItem! // bulk_tabViewItem.tabState.rawValue = 0 if active, 1 if not active
//    @IBOutlet weak var selective_tabViewItem: NSTabViewItem!
//    @IBOutlet weak var bulk_iOS_tabViewItem: NSTabViewItem!
//    @IBOutlet weak var general_tabViewItem: NSTabViewItem!
//    @IBOutlet weak var macOS_tabViewItem: NSTabViewItem!
//    @IBOutlet weak var iOS_tabViewItem: NSTabViewItem!
//    @IBOutlet weak var activeTab_TabView: NSTabView!    // macOS, iOS, general, or selective
//
//    @IBOutlet weak var sectionToMigrate_button: NSPopUpButton!
//    @IBOutlet weak var iOSsectionToMigrate_button: NSPopUpButton!
//    @IBOutlet weak var generalSectionToMigrate_button: NSPopUpButton!
    
    /*
     var migrationMode = ""  // either buld or selective
     
     var platform = ""  // either macOS, iOS, or general
     
     var goSender = ""
     
     // button labels
     // macOS button labels
     @IBOutlet weak var advcompsearch_label_field: NSTextField!
     @IBOutlet weak var macapplications_label_field: NSTextField!
     @IBOutlet weak var computers_label_field: NSTextField!
     @IBOutlet weak var directory_bindings_field: NSTextField!
     @IBOutlet weak var disk_encryptions_field: NSTextField!
     @IBOutlet weak var dock_items_field: NSTextField!
     @IBOutlet weak var file_shares_label_field: NSTextField!
     @IBOutlet weak var sus_label_field: NSTextField!
     @IBOutlet weak var netboot_label_field: NSTextField!
     @IBOutlet weak var osxconfigurationprofiles_label_field: NSTextField!
 //    @IBOutlet weak var patch_mgmt_field: NSTextField!
     @IBOutlet weak var patch_policies_field: NSTextField!
     @IBOutlet weak var extension_attributes_label_field: NSTextField!
     @IBOutlet weak var scripts_label_field: NSTextField!
     @IBOutlet weak var smart_groups_label_field: NSTextField!
     @IBOutlet weak var static_groups_label_field: NSTextField!
     @IBOutlet weak var packages_label_field: NSTextField!
     @IBOutlet weak var printers_label_field: NSTextField!
     @IBOutlet weak var policies_label_field: NSTextField!
     @IBOutlet weak var jamfUserAccounts_field: NSTextField!
     @IBOutlet weak var jamfGroupAccounts_field: NSTextField!
     @IBOutlet weak var restrictedsoftware_label_field: NSTextField!
     @IBOutlet weak var macPrestages_label_field: NSTextField!
     @IBOutlet weak var uploadingIcons_textfield: NSTextField!
     // iOS button labels
     @IBOutlet weak var smart_ios_groups_label_field: NSTextField!
     @IBOutlet weak var static_ios_groups_label_field: NSTextField!
     @IBOutlet weak var mobiledeviceconfigurationprofile_label_field: NSTextField!
     @IBOutlet weak var mobiledeviceextensionattributes_label_field: NSTextField!
     @IBOutlet weak var mobiledevices_label_field: NSTextField!
     @IBOutlet weak var mobiledeviceApps_label_field: NSTextField!
     @IBOutlet weak var advancedmobiledevicesearches_label_field: NSTextField!
     @IBOutlet weak var mobiledevicePrestage_label_field: NSTextField!
     @IBOutlet weak var uploadingIcons2_textfield: NSTextField!
     // general button labels
     @IBOutlet weak var advusersearch_label_field: NSTextField!
     @IBOutlet weak var building_label_field: NSTextField!
     @IBOutlet weak var categories_label_field: NSTextField!
     @IBOutlet weak var departments_label_field: NSTextField!
     @IBOutlet weak var userEA_label_field: NSTextField!
     @IBOutlet weak var sites_label_field: NSTextField!
     @IBOutlet weak var ldapservers_label_field: NSTextField!
     @IBOutlet weak var network_segments_label_field: NSTextField!
     @IBOutlet weak var users_label_field: NSTextField!
     @IBOutlet weak var smartUserGrps_label_field: NSTextField!
     @IBOutlet weak var staticUserGrps_label_field: NSTextField!
     */
    
//    @IBOutlet weak var migrateOrRemove_TextField: NSTextField!
    
    // Source and destination fields
    @IBOutlet weak var source_jp_server_field: NSTextField!
    @IBOutlet weak var source_user_field: NSTextField!
    @IBOutlet weak var source_pwd_field: NSSecureTextField!
    @IBOutlet weak var dest_jp_server_field: NSTextField!
    @IBOutlet weak var dest_user_field: NSTextField!
    @IBOutlet weak var dest_pwd_field: NSSecureTextField!
    
    // Source and destination buttons
    @IBOutlet weak var sourceServerPopup_button: NSPopUpButton!
    @IBOutlet weak var destServerPopup_button: NSPopUpButton!
    @IBOutlet weak var disableExportOnly_button: NSButton!
    
    var isDir: ObjCBool        = false
    let plistPath:String?      = (NSHomeDirectory() + "/Library/Application Support/jamf-migrator/settings.plist")
    var format                 = PropertyListSerialization.PropertyListFormat.xml //format of the property list
    var plistData:[String:Any] = [:]   //our server/username data
    
    var saveRawXmlScope     = true
    var saveTrimmedXmlScope = true
    
    var hideGui             = false
    
    // GET and POST/PUT (DELETE) fields
//    @IBOutlet weak var get_name_field: NSTextField!
//    @IBOutlet weak var getSummary_label: NSTextField!
//    @IBOutlet weak var get_levelIndicator: NSLevelIndicator!

//    @IBOutlet weak var put_name_field: NSTextField!  // object being migrated
//    @IBOutlet weak var putSummary_label: NSTextField!
//
//    @IBOutlet weak var put_levelIndicator: NSLevelIndicator!
//    var put_levelIndicatorFillColor = [String:NSColor]()

    // selective migration items - start
    // source / destination tables
    
//    @IBOutlet var selectiveTabelHeader_textview: NSTextField!
//    @IBOutlet weak var migrateDependencies: NSButton!
//    @IBOutlet weak var srcSrvTableView: NSTableView!
    
    /*
    // selective migration vars
    var advancedMigrateDict     = [Int:[String:[String:String]]]()    // dictionary of dependencies for the object we're migrating - id:category:dictionary of dependencies
    var migratedDependencies    = [String:[Int]]()
    var migratedPkgDependencies = [String:String]()
    var waitForDependencies     = false
    var dependencyParentId      = 0
    var dependencyMigratedCount = [Int:Int]()   // [policyID:number of dependencies]
    
    
    // source / destination array / dictionary of items
    var sourceDataArray            = [String]()
    var staticSourceDataArray      = [String]()
    var targetDataArray            = [String]()
    var availableIDsToMigDict:[String:Int]  = [:]   // something like xmlName, xmlID
    var availableObjsToMigDict:[Int:String] = [:]   // something like xmlID, xmlName
    var availableIdsToDelArray:[Int]        = []   // array of objects' to delete IDs
    var selectiveListCleared                = false
    var delayInt: UInt32                    = 50000
    var createRetryCount                    = [String:Int]()   // objectType-objectID:retryCount
    
    // destination TextFieldCells
    @IBOutlet weak var destTextCell_TextFieldCell: NSTextFieldCell!
    @IBOutlet weak var dest_TableColumn: NSTableColumn!
    // selective migration items - end
    
    // app version label
    @IBOutlet weak var appVersion_TextField: NSTextField!
    
    // smartgroup vars
    var migrateSmartComputerGroups  = false
    var migrateStaticComputerGroups = false
    var migrateSmartMobileGroups    = false
    var migrateStaticMobileGroups   = false
    var migrateSmartUserGroups      = false
    var migrateStaticUserGroups     = false
    
    // command line switches
//    var debug           = false
    var hideGui             = false
//    var export.saveOnly     = false
//    var saveRawXml          = false
//    var saveTrimmedXml      = false
    var saveRawXmlScope     = true
    var saveTrimmedXmlScope = true
    
    // plist and log variables
    var didRun                 = false  // used to determine if the Go! button was selected, if not delete the empty log file only.
    let plistPath:String?      = (NSHomeDirectory() + "/Library/Application Support/jamf-migrator/settings.plist")
    var format                 = PropertyListSerialization.PropertyListFormat.xml //format of the property list
    var plistData:[String:Any] = [:]   //our server/username data
     */

//  Log / backup vars
    let backupDate          = DateFormatter()
    var maxLogFileCount     = 20
    var historyFile: String = ""
    var logFile:     String = ""
    let logPath:    String? = (NSHomeDirectory() + "/Library/Logs/jamf-migrator/")
    var logFileW:     FileHandle? = FileHandle(forUpdatingAtPath: "")
    // legacy logging (history) path and file
    let historyPath:String? = (NSHomeDirectory() + "/Library/Application Support/jamf-migrator/history/")
    var historyFileW: FileHandle? = FileHandle(forUpdatingAtPath: "")
    
    // scope preferences
    var scopeOptions:           Dictionary<String,Dictionary<String,Bool>> = [:]
    var scopeOcpCopy:           Bool = true   // osxconfigurationprofiles copy scope
    var scopeMaCopy:            Bool = true   // macapps copy scope
    var scopeRsCopy:            Bool = true   // restrictedsoftware copy scope
    var scopePoliciesCopy:      Bool = true   // policies copy scope
    var policyPoliciesDisable:  Bool = false  // policies disable on copy
    var scopeMcpCopy:           Bool = true   // mobileconfigurationprofiles copy scope
    var scopeIaCopy:            Bool = true   // iOSapps copy scope
    //    var policyMcpDisable:       Bool = false  // mobileconfigurationprofiles disable on copy
    //    var policyOcpDisable:       Bool = false  // osxconfigurationprofiles disable on copy
    var scopeScgCopy:           Bool = true // static computer groups copy scope
    var scopeSigCopy:           Bool = true // static iOS device groups copy scope
    var scopeUsersCopy:         Bool = true // static user groups copy scope
    
    // xml prefs
    var xmlPrefOptions: Dictionary<String,Bool> = [:]
    
    // site copy / move pref
    var sitePref = ""
    
    var sourceServerArray   = [String]()
    var destServerArray     = [String]()
    
    // credentials
    var sourceCreds = ""
    var destCreds   = ""
    var jamfAdminId = 1
    
    // settings variables
    let safeCharSet                 = CharacterSet.alphanumerics
    var source_jp_server: String    = ""
    var source_user: String         = ""
    var source_pass: String         = ""
    var dest_jp_server: String      = ""
    var dest_user: String           = ""
    var dest_pass: String           = ""
    var sourceBase64Creds: String   = ""
    var destBase64Creds: String     = ""
    
    var sourceURL = ""
//    var destURL = ""
    var createDestUrlBase = ""
    var iconDictArray = [String:[[String:String]]]()
    var uploadedIcons = [String:Int]()
    
    // import file vars
    var fileImport      = false
    var dataFilesRoot   = ""
    
    var endpointDefDict = ["computergroups":"computer_groups", "directorybindings":"directory_bindings", "diskencryptionconfigurations":"disk_encryption_configurations", "dockitems":"dock_items","macapplications":"mac_applications", "mobiledeviceapplications":"mobile_device_application", "mobiledevicegroups":"mobile_device_groups", "packages":"packages", "patches":"patch_management_software_titles", "patchpolicies":"patch_policies", "printers":"printers", "scripts":"scripts", "usergroups":"user_groups", "userextensionattributes":"user_extension_attributes", "advancedusersearches":"advanced_user_searches", "restrictedsoftware":"restricted_software"]
    let ordered_dependency_array = ["sites", "buildings", "categories", "computergroups", "dockitems", "departments", "directorybindings", "distributionpoints", "ibeacons", "packages", "printers", "scripts", "softwareupdateservers", "networksegments"]
    var xmlName             = ""
    var destEPs             = [String:Int]()
    var currentEPs          = [String:Int]()
    var currentLDAPServers  = [String:Int]()
    
    var currentEPDict       = [String:[String:Int]]()
    
    var currentEndpointID   = 0
    var progressCountArray  = [String:Int]() // track if post/put was successful
    
    var whiteText:NSColor   = NSColor.white
    var greenText:NSColor   = NSColor.green
    var yellowText:NSColor  = NSColor.yellow
    var redText:NSColor     = NSColor.red
    var changeColor:Bool    = true
    
    // This order must match the drop down for selective migration, provide the node name: ../JSSResource/node_name
    var generalEndpointArray: [String] = ["advancedusersearches", "buildings", "categories", "departments", "jamfusers", "jamfgroups", "ldapservers", "networksegments", "sites", "userextensionattributes", "users", "smartusergroups", "staticusergroups"]
    var macOSEndpointArray: [String] = ["advancedcomputersearches", "macapplications", "smartcomputergroups", "staticcomputergroups", "computers", "osxconfigurationprofiles", "directorybindings", "diskencryptionconfigurations", "dockitems", "computerextensionattributes", "distributionpoints", "netbootservers", "packages", "policies", "computer-prestages", "printers", "restrictedsoftware", "scripts", "softwareupdateservers"]
    var iOSEndpointArray: [String] = ["advancedmobiledevicesearches", "mobiledeviceapplications", "mobiledeviceconfigurationprofiles", "smartmobiledevicegroups", "staticmobiledevicegroups", "mobiledevices",  "mobiledeviceextensionattributes", "mobile-device-prestages"]
    var AllEndpointsArray = [String]()
    
    
    var getEndpointInProgress = ""     // end point currently in the GET queue
    var endpointInProgress    = ""     // end point currently in the POST queue
    var endpointName          = ""
    var POSTsuccessCount      = 0
    var failedCount           = 0
    var postCount             = 1
    var counters    = Dictionary<String, Dictionary<String,Int>>()          // summary counters of created, updated, failed, and deleted objects
    var getCounters = [String:[String:Int]]()                               // summary counters of created, updated, failed, and deleted objects
    var putCounters = [String:[String:Int]]()
//    var tmp_counter = Dictionary<String, Dictionary<String,Int>>()        // used to hold value of counter and avoid simultaneous access when updating
    var summaryDict = Dictionary<String, Dictionary<String,[String]>>()     // summary arrays of created, updated, and failed objects
    
    // used in createEndpoints
    var totalCreated   = 0
    var totalUpdated   = 0
    var totalFailed    = 0
    var totalCompleted = 0

//    @IBOutlet weak var mySpinner_ImageView: NSImageView!
//    var theImage:[NSImage] = [NSImage(named: "0.png")!,
//                              NSImage(named: "1.png")!,
//                              NSImage(named: "2.png")!]
//    var showSpinner = false
    
    // group counters
    var smartCount      = 0
    var staticCount     = 0
    //var DeviceGroupType = ""  // either smart or static
    // var groupCheckArray: [Bool] = []
    
    
    // define list of items to migrate
    var objectsToMigrate: [String] = []
    var nodesMigrated              = 0
    var objectNode                 = "" // link dependency type to object endpoint. ex. (dependency) category to (endpoint) categories

    // dictionaries to map id of object on source server to id of same object on destination server
//    var computerconfigs_id_map = [String:Dictionary<String,Int>]()
    var bindings_id_map   = [String:Dictionary<String,Int>]()
    var packages_id_map   = [String:Dictionary<String,Int>]()
    var printers_id_map   = [String:Dictionary<String,Int>]()
    var scripts_id_map    = [String:Dictionary<String,Int>]()
    var configObjectsDict = [String:Dictionary<String,String>]()
    var orphanIds         = [String]()
    var idDict            = [String:Dictionary<String,Int>]()
    
    
    let fm            = FileManager()
    var theOpQ        = OperationQueue() // create operation queue for API calls
    var getEndpointsQ = OperationQueue() // create operation queue for API calls
    var theCreateQ    = OperationQueue() // create operation queue for API POST/PUT calls
    var readFilesQ    = OperationQueue() // for reading in data files
    var readNodesQ    = OperationQueue()   // for reading in API endpoints
    let theIconsQ     = OperationQueue() // que to upload/download icons
    
    let theSortQ      = OperationQueue()
    
    var authQ       = DispatchQueue(label: "com.jamf.auth")
    var theModeQ    = DispatchQueue(label: "com.jamf.addRemove")
    var theSpinnerQ = DispatchQueue(label: "com.jamf.spinner")
    var destEPQ     = DispatchQueue(label: "com.jamf.destEPs", qos: DispatchQoS.background)
    var idMapQ      = DispatchQueue(label: "com.jamf.idMap")
    var sortQ       = DispatchQueue(label: "com.jamf.sortQ", qos: DispatchQoS.default)
    var iconHoldQ   = DispatchQueue(label: "com.jamf.iconhold")
    
    var concurrentThreads = 2
    
    var migrateOrWipe: String = ""
    var httpStatusCode: Int = 0
    var URLisValid: Bool = true
    
    @objc func deleteMode_sdvc(_ sender: Any) {
        if (self.fm.fileExists(atPath: NSHomeDirectory() + "/Library/Application Support/jamf-migrator/DELETE", isDirectory: &isDir))  {
            DispatchQueue.main.async { [self] in
                // disable source server, username and password fields (to finish)
                if source_jp_server_field.isEnabled {
//                    source_jp_server_field.textColor   = NSColor.white
                    importFiles_button.isEnabled      = false
                    browseFiles_button.isEnabled      = false
                    source_jp_server_field.isEnabled  = false
                    sourceServerList_button.isEnabled = false
                    source_user_field.isEnabled       = false
                    source_pwd_field.isEnabled        = false
                }
            }
        } else {
            DispatchQueue.main.async { [self] in
                // enable source server, username and password fields (to finish)
                if !source_jp_server_field.isEnabled {
                    importFiles_button.isEnabled      = true
                    browseFiles_button.isEnabled      = true
                    source_jp_server_field.isEnabled  = true
                    sourceServerList_button.isEnabled = true
                    source_user_field.isEnabled       = true
                    source_pwd_field.isEnabled        = true
                }
            }
        }
     }
    
//    @IBAction func showLogFolder(_ sender: Any) {
//        isDir = true
//        if (self.fm.fileExists(atPath: logPath!, isDirectory: &isDir)) {
//            NSWorkspace.shared.openFile(logPath!)
//        } else {
//            _ = Alert().display(header: "Alert", message: "There are currently no log files to display.", secondButton: "")
//        }
//    }
    
    @IBAction func fileImport_action(_ sender: NSButton) {
        if importFiles_button.state.rawValue == 1 {
            let toggleFileImport = (sender.title == "Browse") ? false:true
            
            DispatchQueue.main.async {
                let openPanel = NSOpenPanel()
            
                openPanel.canChooseDirectories = true
                openPanel.canChooseFiles       = false
            
                openPanel.begin { [self] (result) in
                    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                        exportedFilesUrl = openPanel.url
                        dataFilesRoot = (exportedFilesUrl?.absoluteString.replacingOccurrences(of: "file://", with: ""))!
                        dataFilesRoot = dataFilesRoot.replacingOccurrences(of: "%20", with: " ")
        //                print("encoded dataFilesRoot: \(String(describing: dataFilesRoot))")
                        source_jp_server_field.stringValue = dataFilesRoot
                        source_user_field.isHidden         = true
                        source_pwd_field.isHidden          = true
                        fileImport                         = true
                        
                        source_user_field.stringValue      = ""
                        source_pwd_field.stringValue       = ""
                        if LogLevel.debug { WriteToLog().message(stringOfText: "[fileImport] Set source folder to: \(String(describing: dataFilesRoot))\n") }
                        userDefaults.set("\(dataFilesRoot)", forKey: "dataFilesRoot")
                        JamfProServer.importFiles = 1
                        
                        // Note, merge this with xportFilesURL
                        xportFolderPath = openPanel.url
                        
                        userDefaults.synchronize()
                        browseFiles_button.isHidden        = false
                        saveSourceDestInfo(info: plistData)
                    } else {
                        if toggleFileImport {
//                            self.source_jp_server_field.stringValue = ""
                            source_user_field.isHidden         = false
                            source_pwd_field.isHidden          = false
                            fileImport                         = false
                            importFiles_button.state           = NSControl.StateValue(rawValue: 0)
                            JamfProServer.importFiles = 0
                        }
                    }
                } // openPanel.begin - end
            }   // DispatchQueue.main.async - end
        } else {    // if importFiles_button.state - end
            DispatchQueue.main.async {
                self.source_jp_server_field.stringValue = ""
                self.source_user_field.isHidden = false
                self.source_pwd_field.isHidden = false
                self.fileImport = false
                self.importFiles_button.state = NSControl.StateValue(rawValue: 0)
                self.browseFiles_button.isHidden        = true
                JamfProServer.importFiles = 0
            }
        }
    }   // @IBAction func fileImport - end
    
    @IBAction func migrateToSite_action(_ sender: Any) {
        JamfProServer.toSite   = false
        JamfProServer.destSite = "None"
        if siteMigrate_button.state.rawValue == 1 {
            if dest_jp_server_field.stringValue == "" {
                _ = Alert().display(header: "Attention", message: "Destination URL is required", secondButton: "")
                return
            }
            if self.dest_user_field.stringValue == "" || self.dest_pwd_field.stringValue == "" {
                _ = Alert().display(header: "Attention", message: "Credentials for the destination server are required", secondButton: "")
                return
            }
            
            itemToSite = true
            availableSites_button.removeAllItems()
            
            self.destCreds = "\(self.dest_user_field.stringValue):\(self.dest_pwd_field.stringValue)"
            self.destBase64Creds = self.destCreds.data(using: .utf8)?.base64EncodedString() ?? ""

            DispatchQueue.main.async {
                self.siteMigrate_button.isEnabled = false
                self.sitesSpinner_ProgressIndicator.startAnimation(self)
            }
            
            jamfpro!.getToken(whichServer: "destination", serverUrl: "\(dest_jp_server_field.stringValue)", base64creds: destBase64Creds, localSource: false) { [self]
                (authResult: (Int,String)) in
                let (authStatusCode, _) = authResult
                print("authResult: \(authResult)")

                if pref.httpSuccess.contains(authStatusCode) {
                    Sites().fetch(server: "\(dest_jp_server_field.stringValue)", creds: "\(dest_user_field.stringValue):\(dest_pwd_field.stringValue)") { [self]
                        (result: (Int,[String])) in
                        let (httpStatus, destSitesArray) = result
                        if pref.httpSuccess.contains(httpStatus) {
                            if destSitesArray.count == 0 {destinationLabel_TextField.stringValue = "Site"
                                // no sites found - allow migration from a site to none
                                availableSites_button.addItems(withTitles: ["None"])
                            }
                            self.destinationLabel_TextField.stringValue = "Site"
                            self.availableSites_button.addItems(withTitles: ["None"])
                            for theSite in destSitesArray {
                                self.availableSites_button.addItems(withTitles: [theSite])
                            }
                            self.availableSites_button.isEnabled = true
                            JamfProServer.toSite                 = true
                            setDestSite_button.isHidden          = false
                            DispatchQueue.main.async {
                                self.sitesSpinner_ProgressIndicator.stopAnimation(self)
                                self.siteMigrate_button.isEnabled = true
                            }
                        } else {
                            setDestSite_button.isHidden                 = true
                            self.destinationLabel_TextField.stringValue = "Destination"
                            self.availableSites_button.isEnabled = false
                            self.destinationSite = ""
                            itemToSite = false
                            DispatchQueue.main.async {
                                self.sitesSpinner_ProgressIndicator.stopAnimation(self)
                                self.siteMigrate_button.isEnabled = true
                                self.siteMigrate_button.state = NSControl.StateValue(rawValue: 0)
                            }
                        }
                    }
                } else {
                    print("[sites fn] failed to auth")
                    setDestSite_button.isHidden                 = true
                    self.destinationLabel_TextField.stringValue = "Destination"
                    self.availableSites_button.isEnabled = false
                    self.destinationSite = ""
                    itemToSite = false
                    DispatchQueue.main.async {
                        self.sitesSpinner_ProgressIndicator.stopAnimation(self)
                        self.siteMigrate_button.isEnabled = true
                        self.siteMigrate_button.state = NSControl.StateValue(rawValue: 0)
                    }
                }
            }
                
        } else {
            setDestSite_button.isHidden            = true
            destinationLabel_TextField.stringValue = "Destination"
            self.availableSites_button.isEnabled = false
            self.availableSites_button.removeAllItems()
            destinationSite = ""
            itemToSite = false
            DispatchQueue.main.async {
                self.sitesSpinner_ProgressIndicator.stopAnimation(self)
                self.siteMigrate_button.isEnabled = true
            }
        }
        
    }
    
    @IBAction func setDestSite_action(_ sender: Any) {
        JamfProServer.destSite = availableSites_button.selectedItem!.title
    }
    
    func serverChanged(whichserver: String) {
        print("[SourceDestVC] whichServer: \(whichserver)")
        if (whichserver == "source" && !wipeData.on) || (whichserver == "destination" && !export.saveOnly) {
            // post to notification center
            JamfProServer.whichServer = whichserver
            print("[SourceDestVC] post notification for resetListFields")
            NotificationCenter.default.post(name: .resetListFields, object: nil)
        }
    }
   
    func fetchPassword(whichServer: String, url: String) {
        let credentialsArray  = Creds2.retrieve(service: "migrator - "+url.fqdnFromUrl)
        
        if credentialsArray.count == 2 {
            if whichServer == "source" {
                JamfProServer.sourceUser = ""
                JamfProServer.sourcePwd  = ""
                if (url != "") {
                    if setting.fullGUI {
                        source_user_field.stringValue = credentialsArray[0]
                        source_pwd_field.stringValue  = credentialsArray[1]
                        self.storedSourceUser         = credentialsArray[0]
                        self.storedSourcePwd          = credentialsArray[1]
                    } else {
                        source_user = credentialsArray[0]
                        source_pass = credentialsArray[1]
                    }
                    JamfProServer.source     = url
                    JamfProServer.sourceUser = credentialsArray[0]
                    JamfProServer.sourcePwd  = credentialsArray[1]
                }
            } else {
                JamfProServer.destUser   = ""
                JamfProServer.destPwd    = ""
                if (url != "") {
                    if setting.fullGUI {
                        dest_user_field.stringValue = credentialsArray[0]
                        dest_pwd_field.stringValue  = credentialsArray[1]
                        self.storedDestUser         = credentialsArray[0]
                        self.storedDestPwd          = credentialsArray[1]
                    }
                    dest_user = credentialsArray[0]
                    dest_pass = credentialsArray[1]
                    JamfProServer.destination = url
                    JamfProServer.destUser    = credentialsArray[0]
                    JamfProServer.destPwd     = credentialsArray[1]
                } else {
                    if setting.fullGUI {
                        dest_pwd_field.stringValue = ""
                        if source_pwd_field.stringValue != "" {
                            dest_pwd_field.becomeFirstResponder()
                        }
                    }
                }
            }   // if whichServer - end
        } else {
            // credentials not found - blank out username / password fields
            if setting.fullGUI {
                hideCreds_button.state = NSControl.StateValue(rawValue: 1)
                hideCreds_action(self)
                if whichServer == "source" {
                    source_user_field.stringValue = ""
                    source_pwd_field.stringValue = ""
                    self.storedSourceUser = ""
                    source_user_field.becomeFirstResponder()
                } else {
                    dest_user_field.stringValue = ""
                    dest_pwd_field.stringValue = ""
                    self.storedSourceUser = ""
                    dest_user_field.becomeFirstResponder()
                }
            } else {
                WriteToLog().message(stringOfText: "Validate URL and/or credentials are saved for both source and destination Jamf Pro instances.")
                NSApplication.shared.terminate(self)
            }
        }
    }
    
    func readSettings() -> [String:Any] {
        // read environment settings - start
        plistData = (NSDictionary(contentsOf: URL(fileURLWithPath: plistPath!)) as? [String : Any])!
        if plistData.count == 0 {
            if LogLevel.debug { WriteToLog().message(stringOfText: "Error reading plist\n") }
        }
//        print("readSettings - plistData: \(String(describing: plistData))\n")
        return(plistData)
        // read environment settings - end
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            switch textField.identifier!.rawValue {
            case "sourceServer":
                _ = serverOrFiles()
                JamfProServer.source = source_jp_server_field.stringValue
                fetchPassword(whichServer: "source", url: JamfProServer.source)
            case "sourceUser":
                JamfProServer.sourceUser = source_user_field.stringValue
            case "sourcePassword":
                JamfProServer.sourcePwd = source_pwd_field.stringValue
            case "destServer":
                print("identifier: \(textField.identifier!.rawValue)")
                JamfProServer.destination = dest_jp_server_field.stringValue
                fetchPassword(whichServer: "destination", url: JamfProServer.destination)
            case "destUser":
                JamfProServer.destUser = dest_user_field.stringValue
            case "destPassword":
                JamfProServer.destPwd = dest_pwd_field.stringValue
            default:
                break
            }
        }
    }
    
    @IBAction func disableExportOnly_action(_ sender: Any) {
        export.saveOnly       = false
        export.saveRawXml     = false
        export.saveTrimmedXml = false
        plistData["xml"] = ["saveRawXml":export.saveRawXml,
                                "saveTrimmedXml":export.saveTrimmedXml,
                                "saveOnly":export.saveOnly,
                                "saveRawXmlScope":export.rawXmlScope,
                                "saveTrimmedXmlScope":export.trimmedXmlScope]
        savePrefs(prefs: plistData)
        NotificationCenter.default.post(name: .exportOff, object: nil)
        disableSource()
    }
    
    
    func disableSource() {
        if setting.fullGUI {
            DispatchQueue.main.async { [self] in
                dest_jp_server_field.isEnabled      = !export.saveOnly
                destServerList_button.isEnabled     = !export.saveOnly
                dest_user_field.isEnabled           = !export.saveOnly
                dest_pwd_field.isEnabled            = !export.saveOnly
                siteMigrate_button.isEnabled        = !export.saveOnly
                destinationLabel_TextField.isHidden = export.saveOnly
                setDestSite_button.isHidden         = export.saveOnly
                disableExportOnly_button.isHidden   = !export.saveOnly
            }
        }
    }
    
    func savePrefs(prefs: [String:Any]) {
        plistData            = readSettings()
        plistData["scope"]   = prefs["scope"]
        plistData["xml"]     = prefs["xml"]
        scopeOptions         = prefs["scope"] as! Dictionary<String,Dictionary<String,Bool>>
        xmlPrefOptions       = prefs["xml"] as! Dictionary<String,Bool>
//        export.saveOnly            = xmlPrefOptions["saveOnly"]!
        if let _ = xmlPrefOptions["saveOnly"] {
            export.saveOnly = xmlPrefOptions["saveOnly"]!
        } else {
            export.saveOnly = false
        }
        if let _ = xmlPrefOptions["saveRawXml"] {
            export.saveRawXml = xmlPrefOptions["saveRawXml"]!
        } else {
            export.saveRawXml = false
        }
        if let _ = xmlPrefOptions["saveTrimmedXml"] {
            export.saveTrimmedXml = xmlPrefOptions["saveTrimmedXml"]!
        } else {
            export.saveTrimmedXml = false
        }
        if let _ = xmlPrefOptions["saveRawXmlScope"] {
            saveRawXmlScope = xmlPrefOptions["saveRawXmlScope"]!
        } else {
            saveRawXmlScope = false
        }
        if let _ = xmlPrefOptions["saveTrimmedXmlScope"] {
            saveTrimmedXmlScope = xmlPrefOptions["saveTrimmedXmlScope"]!
        } else {
            saveRawXmlScope = false
        }
        NSDictionary(dictionary: plistData).write(toFile: self.plistPath!, atomically: true)
//      print("savePrefs xml: \(String(describing: self.plistData["xml"]))\n")
    }

    // extract the value between xml tags - start
    func tagValue(xmlString:String, xmlTag:String) -> String {
        var rawValue = ""
        if let start = xmlString.range(of: "<\(xmlTag)>"),
            let end  = xmlString.range(of: "</\(xmlTag)", range: start.upperBound..<xmlString.endIndex) {
            rawValue.append(String(xmlString[start.upperBound..<end.lowerBound]))
        } else {
            if LogLevel.debug { WriteToLog().message(stringOfText: "[tagValue] invalid input for tagValue function or tag not found.\n") }
            if LogLevel.debug { WriteToLog().message(stringOfText: "\t[tagValue] tag: \(xmlTag)\n") }
            if LogLevel.debug { WriteToLog().message(stringOfText: "\t[tagValue] xml: \(xmlString)\n") }
        }
        return rawValue
    }
    // extract the value between xml tags - end
    // extract the value between (different) tags - start
    func tagValue2(xmlString:String, startTag:String, endTag:String) -> String {
        var rawValue = ""
        if let start = xmlString.range(of: startTag),
            let end  = xmlString.range(of: endTag, range: start.upperBound..<xmlString.endIndex) {
            rawValue.append(String(xmlString[start.upperBound..<end.lowerBound]))
        } else {
            if LogLevel.debug { WriteToLog().message(stringOfText: "[tagValue2] Start, \(startTag), and end, \(endTag), not found.\n") }
        }
        return rawValue
    }
    //  extract the value between (different) tags - end
    
    func updateServerArray(url: String, serverList: String, theArray: [String]) {
        if url != "" {
            var local_serverArray = theArray
            let positionInList = local_serverArray.firstIndex(of: url)
            if positionInList == nil {
                    local_serverArray.insert(url, at: 0)
            } else if positionInList! > 0 {
                local_serverArray.remove(at: positionInList!)
                local_serverArray.insert(url, at: 0)
            }
            while local_serverArray.count > 10 {
                local_serverArray.removeLast()
            }
            plistData[serverList] = local_serverArray as Any?
            NSDictionary(dictionary: plistData).write(toFile: plistPath!, atomically: true)
            switch serverList {
            case "source_server_array":
                self.sourceServerList_button.removeAllItems()
                for theServer in local_serverArray {
                    if theServer != "" {
                        self.sourceServerList_button.addItems(withTitles: [theServer])
                    }
                    self.sourceServerList_button.addItems(withTitles: [theServer])
                }
                self.sourceServerArray = local_serverArray
            case "dest_server_array":
                self.destServerList_button.removeAllItems()
                for theServer in local_serverArray {
                    if theServer != "" {
                        self.destServerList_button.addItems(withTitles: [theServer])
                    }
                }
                self.destServerArray = local_serverArray
            default: break
            }
        }
        saveSourceDestInfo(info: plistData)
    }
    
    func saveSourceDestInfo(info: [String:Any]) {
        plistData                       = info

        plistData["source_jp_server"]   = source_jp_server_field.stringValue as Any?
        plistData["source_user"]        = source_user_field.stringValue as Any?
        plistData["dest_jp_server"]     = dest_jp_server_field.stringValue as Any?
        plistData["dest_user"]          = dest_user_field.stringValue as Any?
        plistData["storeCredentials"]   = JamfProServer.storeCreds as Any?

        NSDictionary(dictionary: plistData).write(toFile: plistPath!, atomically: true)
        _ = readSettings()
    }
    
    @IBAction func setServerUrl_button(_ sender: NSPopUpButton) {
//        self.selectiveListCleared = false
        print("[SourceDestVC] setServerUrl_button identifier: \(String(describing: sender.identifier!.rawValue))\n")
        switch sender.identifier!.rawValue {
        case "source":
            if source_jp_server_field.stringValue != sourceServerList_button.titleOfSelectedItem! {
                JamfProServer.validToken["source"] = false
                serverChanged(whichserver: "source")
                if sourceServerArray.firstIndex(of: "\(source_jp_server_field.stringValue)") == nil {
                    updateServerArray(url: "\(source_jp_server_field.stringValue)", serverList: "source_server_array", theArray: sourceServerArray)
                }
            }
            JamfProServer.source = sourceServerList_button.titleOfSelectedItem!
            source_jp_server_field.stringValue = sourceServerList_button.titleOfSelectedItem!
            fetchPassword(whichServer: "source", url: self.source_jp_server_field.stringValue)
        case "destination":
            if (self.dest_jp_server_field.stringValue != destServerList_button.titleOfSelectedItem!) && !export.saveOnly {
                JamfProServer.validToken["destination"] = false
                serverChanged(whichserver: "destination")
                if destServerArray.firstIndex(of: "\(dest_jp_server_field.stringValue)") == nil {
                    updateServerArray(url: "\(dest_jp_server_field.stringValue)", serverList: "dest_server_array", theArray: destServerArray)
                }
            }
            JamfProServer.destination = destServerList_button.titleOfSelectedItem!
            self.dest_jp_server_field.stringValue = destServerList_button.titleOfSelectedItem!
            fetchPassword(whichServer: "destination", url: self.dest_jp_server_field.stringValue)
            // reset list of available sites
            if siteMigrate_button.state.rawValue == 1 {
                siteMigrate_button.state = NSControl.StateValue(rawValue: 0)
                availableSites_button.isEnabled = false
                availableSites_button.removeAllItems()
                destinationLabel_TextField.stringValue = "Destination"
                destinationSite = ""
                itemToSite = false
            }
        default: break
        }
        // see if we're migrating from files or a server
        _ = serverOrFiles()
        saveSourceDestInfo(info: plistData)
    }
    
    func serverOrFiles() -> String {
        // see if we last migrated from files or a server
//        print("entered serverOrFiles.")
        var sourceType = ""
        DispatchQueue.main.async { [self] in
            if source_jp_server_field.stringValue != "" {
//                print("prefix: \(source_jp_server_field.stringValue.prefix(4).lowercased())")
                if source_jp_server_field.stringValue.prefix(4).lowercased() == "http" {
//                    print("source: server.")
                    importFiles_button.state    = NSControl.StateValue(rawValue: 0)
                    browseFiles_button.isHidden = true
                    source_user_field.isHidden  = false
                    source_pwd_field.isHidden   = false
                    fileImport                  = false
                    sourceType                  = "server"
                } else {
//                    print("source: local files")
                    importFiles_button.state    = NSControl.StateValue(rawValue: 1)
                    browseFiles_button.isHidden = false
                    dataFilesRoot               = source_jp_server_field.stringValue
                    JamfProServer.source        = source_jp_server_field.stringValue
                    exportedFilesUrl            = URL(string: "file://\(dataFilesRoot.replacingOccurrences(of: " ", with: "%20"))")
                    source_user_field.isHidden  = true
                    source_pwd_field.isHidden   = true
                    fileImport                  = true
                    sourceType                  = "files"
                }
                JamfProServer.importFiles = importFiles_button.state.rawValue
            }
        }
        return(sourceType)
    }
    
    override func viewDidAppear() {
        // set tab order
        // Use interface builder, right click a field and drag nextKeyView to the next
        source_jp_server_field.nextKeyView  = source_user_field
        source_user_field.nextKeyView       = source_pwd_field
        source_pwd_field.nextKeyView        = dest_jp_server_field
        dest_jp_server_field.nextKeyView    = dest_user_field
        dest_user_field.nextKeyView         = dest_pwd_field
        
        initVars()
        
    }   //viewDidAppear - end
    
    @objc func toggleExportOnly(_ notification: Notification) {
        disableSource()
    }
    @objc func updateServerList(_ notification: Notification) {
        updateServerArray(url: JamfProServer.source, serverList: "source_server_array", theArray: self.sourceServerArray)
    }
    
    var jamfpro: JamfPro?
    override func viewDidLoad() {
        super.viewDidLoad()
//        hardSetLdapId = false

//        debug = true
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(deleteMode_sdvc(_:)), name: .deleteMode_sdvc, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleExportOnly(_:)), name: .saveOnlyButtonToggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateServerList(_:)), name: .updateServerList, object: nil)
        
        source_jp_server_field.delegate = self
        source_user_field.delegate      = self
        source_pwd_field.delegate       = self
        dest_jp_server_field.delegate   = self
        dest_user_field.delegate        = self
        dest_pwd_field.delegate         = self
        
        // read maxConcurrentOperationCount setting
//        concurrentThreads = setConcurrentThreads()
//        print("concurrentThreads: \(userDefaults.integer(forKey: "concurrentThreads"))")

//        if LogLevel.debug { WriteToLog().message(stringOfText: "----- Debug Mode -----\n") }
        
        jamfpro = JamfPro(sdController: self)
        
        if !hideGui {
            hideCreds_button.state = NSControl.StateValue(rawValue: userDefaults.integer(forKey: "hideCreds"))
            setWindowSize(setting: hideCreds_button.state.rawValue)
            source_jp_server_field.becomeFirstResponder()
        }
    }   //override func viewDidLoad() - end
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidDisappear() {
        // Insert code here to tear down your application
//        saveSettings()
//        logCleanup()
    }
    
    func initVars() {
        // create log directory if missing - start
        if !fm.fileExists(atPath: logPath!) {
            do {
                try fm.createDirectory(atPath: logPath!, withIntermediateDirectories: true, attributes: nil )
            } catch {
                _ = Alert().display(header: "Error:", message: "Unable to create log directory:\n\(String(describing: logPath))\nTry creating it manually.", secondButton: "")
                exit(0)
            }
        }
        // create log directory if missing - end
        
        maxLogFileCount = (userDefaults.integer(forKey: "logFilesCountPref") < 1) ? 20:userDefaults.integer(forKey: "logFilesCountPref")
        logFile = TimeDelegate().getCurrent().replacingOccurrences(of: ":", with: "") + "_migration.log"
        History.logFile = TimeDelegate().getCurrent().replacingOccurrences(of: ":", with: "") + "_migration.log"

        isDir = false
        if !(fm.fileExists(atPath: logPath! + logFile, isDirectory: &isDir)) {
            fm.createFile(atPath: logPath! + logFile, contents: nil, attributes: nil)
        }
        sleep(1)
        
        if !(fm.fileExists(atPath: userDefaults.string(forKey: "saveLocation") ?? ":missing:", isDirectory: &isDir)) {
            print("resetting export location")
            userDefaults.setValue(NSHomeDirectory() + "/Downloads/Jamf Migrator/", forKey: "saveLocation")
            userDefaults.synchronize()
        }
        
        if setting.fullGUI {
            if !FileManager.default.fileExists(atPath: plistPath!) {
                do {
                    try FileManager.default.copyItem(atPath: Bundle.main.path(forResource: "settings", ofType: "plist")!, toPath: plistPath!)
                } catch {
                    WriteToLog().message(stringOfText: "Unable to find/create \(plistPath!)\n")
                    WriteToLog().message(stringOfText: "Try to manually copy the file from ~/Library/Containers/com.jamf.jamf-migrator/Data/Library/Application\\ Support/jamf-migrator/settings.plist to \(plistPath!)\n")
                    NSApplication.shared.terminate(self)
                }
            }
            
            
            // read environment settings from plist - start
            plistData = readSettings()

            if plistData["source_jp_server"] as? String != nil {
                source_jp_server = plistData["source_jp_server"] as! String
                
                if setting.fullGUI {
                    source_jp_server_field.stringValue = source_jp_server
                    if source_jp_server.count > 0 {
                        self.browseFiles_button.isHidden = (source_jp_server.first! == "/") ? false:true
                    }
                }
            } else {
                if setting.fullGUI {
                    self.browseFiles_button.isHidden = true
                }
            }
            
            if plistData["source_user"] != nil {
                source_user = plistData["source_user"] as! String
                if setting.fullGUI {
                    source_user_field.stringValue = source_user
                }
                storedSourceUser = source_user
            }
            
            if plistData["dest_jp_server"] != nil {
                dest_jp_server = plistData["dest_jp_server"] as! String
                if setting.fullGUI {
                    dest_jp_server_field.stringValue = dest_jp_server
                }
            }
            
            if plistData["dest_user"] != nil {
                dest_user = plistData["dest_user"] as! String
                if setting.fullGUI {
                    dest_user_field.stringValue = dest_user
                }
            }
            
            if setting.fullGUI {
                if plistData["source_server_array"] != nil {
                    sourceServerArray = plistData["source_server_array"] as! [String]
                    for theServer in sourceServerArray {
                        self.sourceServerList_button.addItems(withTitles: [theServer])
                    }
                }
                if plistData["dest_server_array"] != nil {
                    destServerArray = plistData["dest_server_array"] as! [String]
                    for theServer in destServerArray {
                        self.destServerList_button.addItems(withTitles: [theServer])
                    }
                }
            }
            if plistData["storeCredentials"] != nil {
                JamfProServer.storeCreds = plistData["storeCredentials"] as! Int
                if setting.fullGUI {
                    storeCredentials_button.state = NSControl.StateValue(rawValue: JamfProServer.storeCreds)
                }
            }
            /*
             // read in ViewController
             
            // read scope settings - start
            if plistData["scope"] != nil {
                scopeOptions = plistData["scope"] as! Dictionary<String,Dictionary<String,Bool>>

                if scopeOptions["mobiledeviceconfigurationprofiles"]!["copy"] != nil {
                    scopeMcpCopy = scopeOptions["mobiledeviceconfigurationprofiles"]!["copy"]!
                }
                if self.scopeOptions["macapps"] != nil {
                    if self.scopeOptions["macapps"]!["copy"] != nil {
                        self.scopeMaCopy = self.scopeOptions["macapps"]!["copy"]!
                    } else {
                        self.scopeMaCopy = true
                    }
                } else {
                    self.scopeMaCopy = true
                }
                if scopeOptions["policies"]!["copy"] != nil {
                    scopePoliciesCopy = scopeOptions["policies"]!["copy"]!
                }
                if scopeOptions["policies"]!["disable"] != nil {
                    policyPoliciesDisable = scopeOptions["policies"]!["disable"]!
                }
                if scopeOptions["osxconfigurationprofiles"]!["copy"] != nil {
                    scopeOcpCopy = scopeOptions["osxconfigurationprofiles"]!["copy"]!
                }
                if scopeOptions["restrictedsoftware"]!["copy"] != nil {
                    scopeRsCopy = scopeOptions["restrictedsoftware"]!["copy"]!
                }
                if self.scopeOptions["iosapps"] != nil {
                    if self.scopeOptions["iosapps"]!["copy"] != nil {
                        self.scopeIaCopy = self.scopeOptions["iosapps"]!["copy"]!
                    } else {
                        self.scopeIaCopy = true
                    }
                } else {
                    self.scopeIaCopy = true
                }
            } else {
                // reset/initialize new settings
                plistData          = readSettings()
                plistData["scope"] = ["osxconfigurationprofiles":["copy":true],
                                      "macapps":["copy":true],
                                      "policies":["copy":true,"disable":false],
                                      "restrictedsoftware":["copy":true],
                                      "mobiledeviceconfigurationprofiles":["copy":true],
                                      "iosapps":["copy":true],
                                      "scg":["copy":true],
                                      "sig":["copy":true],
                                      "users":["copy":true]] as Any
                
                NSDictionary(dictionary: plistData).write(toFile: plistPath!, atomically: true)
            }
            // read scope settings - end
            
            if scopeOptions["scg"] != nil && scopeOptions["sig"] != nil && scopeOptions["users"] != nil  {

                if (scopeOptions["scg"]!["copy"] != nil) {
                    scopeScgCopy = scopeOptions["scg"]!["copy"]!
                } else {
                    scopeScgCopy                  = true
                    scopeOptions["scg"]!["copy"] = scopeScgCopy
                }

                if (scopeOptions["sig"]!["copy"] != nil) {
                    scopeSigCopy = scopeOptions["sig"]!["copy"]!
                } else {
                    scopeSigCopy                  = true
                    scopeOptions["sig"]!["copy"] = scopeSigCopy
                }

                if (scopeOptions["sig"]!["users"] != nil) {
                    scopeUsersCopy = scopeOptions["sig"]!["users"]!
                } else {
                    scopeUsersCopy                 = true
                    scopeOptions["sig"]!["users"] = scopeUsersCopy
                }
            } else {
                // reset/initialize scope preferences
                plistData          = readSettings()
                plistData["scope"] = ["osxconfigurationprofiles":["copy":true],
                                      "macapps":["copy":true],
                                      "policies":["copy":true,"disable":false],
                                      "restrictedsoftware":["copy":true],
                                      "mobiledeviceconfigurationprofiles":["copy":true],
                                      "iosapps":["copy":true],
                                      "scg":["copy":true],
                                      "sig":["copy":true],
                                      "users":["copy":true]] as Any
            }
             */
            
            // read xml settings - start
            if plistData["xml"] != nil {
                xmlPrefOptions       = plistData["xml"] as! Dictionary<String,Bool>

                if (xmlPrefOptions["saveRawXml"] != nil) {
                    export.saveRawXml = xmlPrefOptions["saveRawXml"]!
                } else {
                    export.saveRawXml = false
                    xmlPrefOptions["saveRawXml"] = export.saveRawXml
                }
                
                if (xmlPrefOptions["saveTrimmedXml"] != nil) {
                    export.saveTrimmedXml = xmlPrefOptions["saveTrimmedXml"]!
                } else {
                    export.saveTrimmedXml = false
                    xmlPrefOptions["saveTrimmedXml"] = export.saveTrimmedXml
                }

                if (xmlPrefOptions["saveOnly"] != nil) {
                    export.saveOnly = xmlPrefOptions["saveOnly"]!
                } else {
                    export.saveOnly = false
                    xmlPrefOptions["saveOnly"] = export.saveOnly
                }
                disableSource()
                
                if xmlPrefOptions["saveRawXmlScope"] == nil {
                    xmlPrefOptions["saveRawXmlScope"] = true
                    saveRawXmlScope = true
                }
                if xmlPrefOptions["saveTrimmedXmlScope"] == nil {
                    xmlPrefOptions["saveTrimmedXmlScope"] = true
                    saveTrimmedXmlScope = true
                }
            } else {
                // set default values
                plistData        = readSettings()
                plistData["xml"] = ["saveRawXml":false,
                                    "saveTrimmedXml":false,
                                    "export.saveOnly":false,
                                    "saveRawXmlScope":true,
                                    "saveTrimmedXmlScope":true] as Any
            }
            // update plist
            NSDictionary(dictionary: plistData).write(toFile: plistPath!, atomically: true)
            // read xml settings - end
            // read environment settings - end
            
            // see if we last migrated from files or a server
            // no need to backup local files, add later?
            _ = serverOrFiles()
        } else {
//            didRun = true
            source_jp_server = JamfProServer.source
            dest_jp_server   = JamfProServer.destination
        }

        // check for stored passwords - start
        if (source_jp_server != "") {
            fetchPassword(whichServer: "source", url: source_jp_server)
        }
        if (dest_jp_server != "") {
            fetchPassword(whichServer: "destination", url: dest_jp_server)
        }
        if (storedSourcePwd == "") || (storedDestPwd == "") {
            self.validCreds = false
        }
//        if (source_pwd_field.stringValue == "") || (dest_pwd_field.stringValue == "") {
//            self.validCreds = false
//        }
        // check for stored passwords - end
        /*
        let appVersion = appInfo.version
        let appBuild   = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        WriteToLog().message(stringOfText: "jamf-migrator Version: \(appVersion) Build: \(appBuild )\n")
        
        if !setting.fullGUI {
            WriteToLog().message(stringOfText: "Running silently\n")
            Go(sender: "silent")
        }
         */

    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

extension Notification.Name {
    public static let deleteMode_sdvc      = Notification.Name("deleteMode_sdvc")
    public static let saveOnlyButtonToggle = Notification.Name("toggleExportOnly")
    public static let updateServerList     = Notification.Name("updateServerList")
}