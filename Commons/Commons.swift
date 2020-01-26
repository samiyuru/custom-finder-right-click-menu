//
//  Commons.swift
//  Commons
//
//  Created by Samiyuru Senarathne on 1/25/20.
//  Copyright © 2020 Samiyuru Senarathne. All rights reserved.
//

import Foundation

public let MENU_ITEM_CLICKED_NOTIF = "menuItemClickedNotif"
public let MENU_ITEM_INFO_NOTIF = "menuItemInfoNotif"
public let MENU_ITEM_INFO_REQUEST_NOTIF = "menuItemInfoRequestNotif"

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
