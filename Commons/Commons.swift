//
//  Commons.swift
//  Commons
//
//  Created by Samiyuru Senarathne on 1/25/20.
//  Copyright © 2020 Samiyuru Senarathne.
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

import Foundation

public let MENU_ITEM_CLICKED_NOTIF = "menuItemClickedNotif"
public let MENU_ITEM_INFO_NOTIF = "menuItemInfoNotif"
public let MENU_ITEM_INFO_REQUEST_NOTIF = "menuItemInfoRequestNotif"

// Get the directory for the menu item programs.
// The programs can be apple scripts, bash scripts or executables.
public func programsDir() -> URL {
    // Name of the menu programs directory.
    let menuProgramsDirName = ".findermenu"
    
    // Get the path to user home dir.
    let scriptParentDirURL = FileManager.default.homeDirectoryForCurrentUser

    // Get the URL for menu programs dir path.
    let menuProgramsDirURL = scriptParentDirURL.appendingPathComponent(menuProgramsDirName)
    
    return menuProgramsDirURL
}

// Class to represent an item in the right click menu.
public class MenuItemInfo: Encodable, Decodable {
    
    public var id: Int
    public var title: String
    
    public init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    public static func fromJson(menuItemInfosStr: String?) -> [MenuItemInfo]? {
        guard let jsonData = menuItemInfosStr?.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode([MenuItemInfo].self, from: jsonData)
    }
    
    public static func json(menuItemInfos: [MenuItemInfo]?) -> String? {
        guard let jsonData =  (try? JSONEncoder().encode(menuItemInfos)) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
}

// Class to represent a click of a right click item.
public class MenuItemClickInfo: Encodable, Decodable {
    
    public var id: Int
    public var target: String
    
    public init(id: Int, target: String) {
        self.id = id
        self.target = target
    }
    
    public static func fromJson(str: String?) -> MenuItemClickInfo? {
        guard let jsonData = str?.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(MenuItemClickInfo.self, from: jsonData)
    }
    
    public func json() -> String? {
        guard let jsonData =  (try? JSONEncoder().encode(self)) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
}
