//
//  AJNetworkConfig.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation


/// Global Network Config
public class AJNetworkConfig: NSObject {
    
    public static let shareInstance:AJNetworkConfig = AJNetworkConfig();
    
    
    /// global network request host path
    public var host:String? = nil;
    /// https request certificate password
    public var httpsCerPW:String? = nil;
    /// https request certificate bundle path
    public var httpsCerPath:String? = nil;
    /// custom hub delegate
    public var hubHanlder:AJHubPlugin? = nil;
    
    
    private override init() {
        super.init();
    }
    
}
