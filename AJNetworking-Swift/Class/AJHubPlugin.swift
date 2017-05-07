//
//  AJHubPlugin.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation

/// Tips Show Handler for Http Request Progress
public protocol AJHubPlugin {
    
    func showHub(tips:String?);
    func dismissHub();
}
