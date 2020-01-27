//
//  main.swift
//  FinderMenu
//
//  Created by Samiyuru Senarathne on 1/22/20.
//  Copyright © 2020 Samiyuru Senarathne. All rights reserved.
//

import Cocoa
import FinderSync
import Commons

// The name of the launch agent (in plist).
let launchAgentName = "com.samiyuru.findermenu-service"

// AppDelegate that is used in main.swift top level code.
class AppDelegate: NSObject, NSApplicationDelegate {

    // This is called after the application is launched by the main.swift.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Open extension preferences if the extension is not enabled.
        if !FIFinderSyncController.isExtensionEnabled {
            FIFinderSyncController.showExtensionManagementInterface()
        }
        
        // Exit the application because the application is just the carrier
        // of the Finder Sync extension.
        NSApplication.shared.terminate(self)
    }
    
}

// Show error alert.
func errorAlert(text: String) {
    let alert = NSAlert()
    alert.messageText = "Error occured!"
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "OK")
    alert.runModal()
}

// Get the URL of the user's launch agents directory.
func launchAgentsDirURL() -> URL {
    return FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library")
        .appendingPathComponent("LaunchAgents")
}

// Copy file in the bundle.
func copyFile(fileName: String, fileExt: String, detination: URL) -> Bool? {
    // Access file.
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExt) else {
        errorAlert(text: "Failed to locate script file.")
        return nil
    }
    
    // Try to delete destination.
    try? FileManager.default.removeItem(at: detination)
    
    // Copy file.
    do {
        try FileManager.default.copyItem(at: fileURL, to: detination)
        return true
    } catch {
        return false
    }
}

// Copy the default right click menu scripts available in the bundle to
// the ~/FinderMenu dir.
func copyDefaultScripts() {
    // Create the programs dir.
    let programsDirUrl = programsDir()
    do {
        try FileManager.default.createDirectory(at: programsDirUrl, withIntermediateDirectories: true)
    } catch {
        errorAlert(text: "Failed to create programs directory.")
        return
    }
    
    // Copy scripts.
    if (!(copyFile(fileName: "Open Terminal Here", fileExt: "sh", detination: programsDir().appendingPathComponent("Open Terminal Here.sh")) ?? false)
        || !(copyFile(fileName: "Open Text File Here", fileExt: "sh", detination: programsDir().appendingPathComponent("Open Text File Here.sh")) ?? false)){
        errorAlert(text: "Failed to copy scripts.")
    }
}

// Create the plist with exec path.
func generateAndCopyPlist() -> Bool {
    guard let plistURL = Bundle.main.url(forResource: launchAgentName, withExtension: "plist") else {
        errorAlert(text: "Failed to locate plist file.")
        return false
    }
    do {
        var plistStr = try String(contentsOf: plistURL, encoding: .utf8)
        guard let serviceExecURL = Bundle.main.resourceURL?
                .appendingPathComponent("RightClickService.app")
                .appendingPathComponent("Contents")
                .appendingPathComponent("MacOS")
                .appendingPathComponent("RightClickService") else {
            errorAlert(text: "Failed to locate service executable.")
            return false
        }
        plistStr = String(format: plistStr, serviceExecURL.path)
        let launchAgentURL = launchAgentsDirURL().appendingPathComponent("\(launchAgentName).plist")
        try plistStr.write(to: launchAgentURL, atomically: false, encoding: .utf8)
        return true
    }
    catch {
        errorAlert(text: "Failed to copy plist file.")
        return false
    }
}

// Run script to launch the launch agent for right click service.
func initLaunchd() {
    if (!generateAndCopyPlist()) {
        return
    }
    guard let serviceInitScriptURL = Bundle.main.url(forResource: "install-service", withExtension: "sh") else {
        errorAlert(text: "Failed to locate service initializer script.")
        return
    }
    
    // Initialize termination handler closure.
    let terminationHandler = {
        (process: Process) -> Void in
        NSLog("Script terminated \(process.terminationStatus).")
        if (process.terminationStatus != 0) {
            errorAlert(text: "Failed setup the right click service.")
        }
    }
    
    // Run script.
    guard let _ = try? Process.run(serviceInitScriptURL, arguments: [launchAgentName], terminationHandler: terminationHandler) else {
        errorAlert(text: "Failed to run the process.")
        return
    }
    
    NSLog("launchd setup completed.")
}

// Initalize AppDeligate and set it as the deligate of the app.
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

// Copy the default right cick script files to ~/FinderMenu.
copyDefaultScripts()

// Initialize launch agent for right click service.
initLaunchd()

// Start application run loop.
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
