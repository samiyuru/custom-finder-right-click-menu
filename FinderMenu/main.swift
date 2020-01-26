//
//  main.swift
//  FinderMenu
//
//  Created by Samiyuru Senarathne on 1/22/20.
//  Copyright © 2020 Samiyuru Senarathne. All rights reserved.
//

import Cocoa
import FinderSync

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

// Initalize AppDeligate and set it as the deligate of the app.
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

// Start application run loop.
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
