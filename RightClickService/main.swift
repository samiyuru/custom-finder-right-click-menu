//
//  main.swift
//  FinderMenu
//
//  Created by Samiyuru Senarathne on 1/22/20.
//  Copyright © 2020 Samiyuru Menik.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY
//  OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
//  OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
//  OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa
import Commons

// Types of scripts.
enum ScriptTypes {
    case applescript
    case shellscript
    case executable
}

// Class to hold script information.
public class ScriptInfo {
    
    // Creating instance variables.
    var id: Int = 0
    var title: String
    var path: URL
    var type: ScriptTypes
    
    // Constructor for the class.
    init(title: String, path: URL, type: ScriptTypes) {
        self.title = title
        self.path = path
        self.type = type
    }
}

// Class to hold functions related to menu item scripts.
class MenuItemManager {
    
    // Dictionary to associate script info with menu items using script info array index.
    var scriptInfos: [ScriptInfo]?
    
    // Constructor for menu item manager.
    init() {
        // Read script paths and create script info.
        self.scriptInfos = readScriptPaths()
    }
    
    // Theere is a defined directory to save menu item scripts.
    // Script file name defines the title and the extension defines the type.
    // Each script is loaded as a ScriptInfo object containing title, path, type.
    func readScriptPaths() -> [ScriptInfo]? {
        // Get the URL for menu programs dir path.
        let menuProgramsDirURL = programsDir()
        
        // Log script dir URL.
        NSLog("Script dir located at \(menuProgramsDirURL).")
        
        // Check if the path is a directory.
        if (!menuProgramsDirURL.hasDirectoryPath || !((try? menuProgramsDirURL.checkResourceIsReachable()) ?? false)) {
            NSLog("Scripts path is not a directory at \(menuProgramsDirURL).")
            return nil
        }
        
        // Iterate files in scripts directory.
        guard let fileURLs = (try? FileManager.default.contentsOfDirectory(at: menuProgramsDirURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)) else {
            NSLog("Failed to read files in \(menuProgramsDirURL).")
            return nil
        }
        
        // Create script info array.
        var scriptInfoArray: [ScriptInfo] = []
        
        for fileURL in fileURLs {
            if let scriptInfo = createScriptInfo(scriptPath: fileURL) {
                // Tag is used to associate menu item with script info using array index.
                scriptInfo.id = scriptInfoArray.count
                scriptInfoArray.append(scriptInfo)
            }
        }
        
        return scriptInfoArray
    }
    
    // Get the script type from URL.
    func getScriptType(scriptPath: URL) -> ScriptTypes? {
        // Get the extension of the URL. Can be empty.
        let fileExtension = scriptPath.pathExtension.lowercased();
        
        // Applescript extensions.
        let appleScriptExts = ["scpt", "scptd", "applescript"]
        
        // Shell script extensions.
        let shellScriptExts = ["sh"]
        
        // Check if the extension is apple script.
        if appleScriptExts.contains(fileExtension) {
            return ScriptTypes.applescript
        } else if shellScriptExts.contains(fileExtension) {
            return ScriptTypes.shellscript
        } else if (fileExtension.isEmpty) {
            return ScriptTypes.executable
        } else {
            return nil
        }
    }
    
    // Create a script info object for the script path URL.
    func createScriptInfo(scriptPath: URL) -> ScriptInfo? {
        // Check if the path is a file.
        if !scriptPath.isFileURL || !((try? scriptPath.checkResourceIsReachable()) ?? false) {
            NSLog("Script is not a file or not accessible at \(scriptPath)");
            return nil
        }
        
        // Check if the file type is supported
        guard let fileType = getScriptType(scriptPath: scriptPath) else {
            NSLog("Unsupported script type \(scriptPath).")
            return nil
        }
        
        // Get the file name from URL.
        let scriptName = scriptPath.deletingPathExtension().lastPathComponent
        // Check if the file name exists.
        if scriptName.isEmpty {
            NSLog("File name is not available to get.")
            return nil
        }
        
        // Return scrip info object.
        return ScriptInfo(title: scriptName, path: scriptPath, type: fileType)
    }
    
    // Run script using the script info dictionary and provide target as a parameter.
    func runScript(scriptInfo: ScriptInfo?, target: URL) {
        NSLog("Runing script \(String(describing: scriptInfo)) for \(target).")
        
        guard let scriptInfo = scriptInfo else {
            NSLog("Script info not available.")
            return
        }
        
        // Initialize termination handler closure.
        let terminationHandler = {
            (process: Process) -> Void in
            NSLog("Script terminated \(process.terminationStatus).")
        }
        
        // required parameters.
        var programURL: URL
        var arguments: [String]
        
        // Initialize parameters according to the script type.
        switch scriptInfo.type {
        case ScriptTypes.applescript:
            programURL = URL(fileURLWithPath: "/usr/bin/osascript")
            arguments = [scriptInfo.path.path, target.path]
        case ScriptTypes.shellscript:
            programURL = URL(fileURLWithPath: "/bin/bash")
            arguments = [scriptInfo.path.path, target.path]
        case ScriptTypes.executable:
            programURL = scriptInfo.path
            arguments = [target.path]
        }
        
        // Run the process.
        guard let _ = try? Process.run(programURL, arguments: arguments, terminationHandler: terminationHandler) else {
            NSLog("Failed to run the process.")
            return
        }
    }
    
}

// Class responsible for handling notifications.
class NotificationHandler {
    
    private let menuItemManager: MenuItemManager
    
    init(menuItemManager: MenuItemManager) {
        self.menuItemManager = menuItemManager
        
        // Send the mnu item infos after reading the scripts in case the Finder Extension is already started and handler missed the request.
        sendMenuItemInfosNotification()
    }
    
    // Convert script info array to menu item info array.
    func createMenuInfos(scriptInfos: [ScriptInfo]?) -> [MenuItemInfo]? {
        // Guarded unwrap.
        guard let scriptInfos = scriptInfos else {
            return nil
        }
        
        // Convert the array.
        var menuItemInfos = [MenuItemInfo]()
        for scriptInfo:ScriptInfo in scriptInfos {
            let menuItemInfo = MenuItemInfo(id: scriptInfo.id, title: scriptInfo.title)
            menuItemInfos.append(menuItemInfo)
        }
        
        // Return menu items info array.
        return menuItemInfos
    }
    
    // Send the menu items infos to the finder extension.
    func sendMenuItemInfosNotification() {
        NSLog("\(MENU_ITEM_INFO_NOTIF) sending...")
        
        // reference the notification center.
        let notifCenter = DistributedNotificationCenter.default()
        
        // Get menu items info.
        let menuItemsInfos = createMenuInfos(scriptInfos: self.menuItemManager.scriptInfos)
        
        // Convert to json.
        guard let menuItemsInfoJson = MenuItemInfo.json(menuItemInfos: menuItemsInfos) else {
            NSLog("Failed to convert menuItemsInfoJson to json.")
            return
        }
        
        // Post the notification.
        notifCenter.post(name: Notification.Name(rawValue: MENU_ITEM_INFO_NOTIF),
                         object: menuItemsInfoJson)
    }
    
    // Menu item info request handler.
    @objc func onMenuItemInfoRequest(notification: NSNotification) {
        NSLog("\(MENU_ITEM_INFO_REQUEST_NOTIF) received \(notification.object as? String ?? "").")
        sendMenuItemInfosNotification()
    }
    
    // Menu item info request hendler.
    @objc func onMenuItemClicked(notification: NSNotification) {
        // Get the onject as string.
        guard let menuItemClickInfosJsonStr = (notification.object as? String) else {
            NSLog("Failed to convert the notification object to json string.")
            return
        }
        
        // Log the notification.
        NSLog("\(MENU_ITEM_CLICKED_NOTIF) received \(menuItemClickInfosJsonStr).")
        
        // Convert json to menu item infos.
        guard let menuItemClickInfo = MenuItemClickInfo.fromJson(str: menuItemClickInfosJsonStr) else {
            NSLog("Failed to convert json to menu item info array.")
            return
        }
        
        // Get target URL.
        let target = URL(fileURLWithPath: menuItemClickInfo.target)
        
        // Get ScriptInfo object.
        let scriptInfo = menuItemManager.scriptInfos?[menuItemClickInfo.id]
        
        // Run script.
        menuItemManager.runScript(scriptInfo: scriptInfo, target: target)
    }
    
    // Start hadeling notifications from the finder extension.
    func handleNotifactions() {
        // reference the notification center.
        let notifCenter = DistributedNotificationCenter.default()
        
        // Add observer to listen to click events.
        notifCenter.addObserver(self,
                                selector: #selector(onMenuItemInfoRequest),
                                name: Notification.Name(rawValue: MENU_ITEM_INFO_REQUEST_NOTIF),
                                object: nil)
        
        // Add observer to listen to info requests.
        notifCenter.addObserver(self,
                                selector: #selector(onMenuItemClicked),
                                name: Notification.Name(rawValue: MENU_ITEM_CLICKED_NOTIF),
                                object: nil)
    }
    
}

// Log the service start.
NSLog("Starting the service...")

// Initialize a menu item manager.
let menuItemManager = MenuItemManager()

// Initialize notification handler.
let notificationHandler = NotificationHandler(menuItemManager: menuItemManager)

// Start handling notifications.
notificationHandler.handleNotifactions()

// Start the run loop.
RunLoop.current.run()

