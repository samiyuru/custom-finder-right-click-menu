//
//  FinderSync.swift
//  RightClickItems
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
import FinderSync
import Commons

// This class is the primary class that is referred to in the plist of the Finder Sync extension.
class RightClickActions: FIFinderSync {
    
    // Cached menu instance.
    var menu: NSMenu?
    
    // Constructor of the class.
    override init() {
        super.init()
        
        // Log the nitialization.
        NSLog("RightClickActions() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
        
        // Register notification handler.
        let notifCenter = DistributedNotificationCenter.default()
        notifCenter.addObserver(self,
                                selector: #selector(onMenuItemInfo),
                                name: Notification.Name(rawValue: MENU_ITEM_INFO_NOTIF),
                                object: nil)
        
        // Request menu item info.
        sendMenuItemInfoRequestNtotification()
    }
    
    // handler that will be called when menu item info array is sent.
    @objc func onMenuItemInfo(notification: NSNotification) {
        // Access the object as String.
        guard let menuItemInfosJsonStr = (notification.object as? String) else {
            NSLog("Failed to convert the notification object to json string.")
            return
        }
        
        // Log the notification.
        NSLog("\(MENU_ITEM_INFO_NOTIF) received \(menuItemInfosJsonStr).")
        
        // Convert json to menu item infos.
        guard let menuItemInfos = MenuItemInfo.fromJson(menuItemInfosStr: menuItemInfosJsonStr) else {
            NSLog("Failed to convert json to menu item info array.")
            return
        }
        
        // Create and update the menu according to the new menu item infos.
        self.menu = createMenu(menuItemInfos: menuItemInfos)
    }
    
    // Create a menu item with a given name and a URL association.
    func createMenuItem(menuItemInfo:MenuItemInfo) -> NSMenuItem {
        let menuItem = NSMenuItem(title: menuItemInfo.title, action: #selector(menuItemAction(_:)), keyEquivalent:"");
        // Associate script info with menu item using script info index.
        menuItem.tag = menuItemInfo.id
        return menuItem
    }
    
    // Create a menu by reading the config file.
    func createMenu(menuItemInfos: [MenuItemInfo]?) -> NSMenu? {
        // Guared unwrap script info array.
        guard let menuItemInfos = menuItemInfos else {
            return nil
        }
        
        // Initialize menu object.
        let menu = NSMenu()
        
        // Create a menue item for each script info dict in the array.
        for menuItemInfo in menuItemInfos {
            let menuItem = createMenuItem(menuItemInfo: menuItemInfo)
            menu.addItem(menuItem)
        }
        
        return menu
    }
    
    // Send menu intem info request to the right click service.
    func sendMenuItemInfoRequestNtotification() {
        NSLog("\(MENU_ITEM_INFO_REQUEST_NOTIF) sending...")
        
        // Reference to notification center.
        let notifCenter = DistributedNotificationCenter.default()
        
        // Post the notification.
        notifCenter.post(name: Notification.Name(rawValue: MENU_ITEM_INFO_REQUEST_NOTIF),
                         object: nil)
    }
    
    // Send notification to the command service when right click item is clicked.
    func sendMenuItemClickedNotification(id: Int, target: URL) {
        NSLog("\(MENU_ITEM_CLICKED_NOTIF) sending...")
        
        // Reference to notification center.
        let notifCenter = DistributedNotificationCenter.default()
        
        // Create a json of click info.
        let menuItemClickInfo = MenuItemClickInfo(id: id, target: target.path)
        
        guard let menuItemClickInfoJson = menuItemClickInfo.json() else {
            NSLog("Failed to deserialize menu item click info.")
            return
        }
        
        // Post the notification.
        notifCenter.post(name: Notification.Name(rawValue: MENU_ITEM_CLICKED_NOTIF),
                         object: menuItemClickInfoJson)
    }
    
    // Action handler of each manu item.
    @objc func menuItemAction(_ sender: AnyObject?) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to retrieve the target directory.")
            return
        }
        
        // Get menu item from the sender.
        guard let menuItem = sender as? NSMenuItem else {
            NSLog("Sender menu item is not retrievable.");
            return
        }
        
        // Send click notification.
        sendMenuItemClickedNotification(id: menuItem.tag, target: target)
    }
    
    // Provide a list of menu items for the right click menu.
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Identify finder open directory background click.
        if (menuKind == FIMenuKind.contextualMenuForContainer){
            NSLog("Directory background right click.")
            
            // Retturn the menu from the instance variable.
            return self.menu
        } else {
            NSLog("Not a directory background.")
            
            // Return no menu.
            return nil
        }
    }
    
}

