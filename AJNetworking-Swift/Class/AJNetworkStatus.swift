//
//  AJNetworkStatus.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation
import Alamofire


public enum AJNetworkReachability {
    case unknown
    case notReachable
    case wwan
    case wifi
}


public class AJNetworkStatus: NSObject {
    
    private var reachability:NetworkReachabilityManager = NetworkReachabilityManager(host: "www.so.com")!;
    
    private override init() {
        super.init();
        
        weak var weakSelf = self;
        reachability.listener = { status in
            
            switch status {
            case .notReachable:
                weakSelf!.currentStatus = .notReachable;
                
            case .unknown:
                weakSelf!.currentStatus = .unknown;
                
            case .reachable(let type):
                switch type {
                case .ethernetOrWiFi:
                    weakSelf!.currentStatus = .wifi;
                    
                case .wwan:
                    weakSelf!.currentStatus = .wwan;
                }
            }
            
            if weakSelf!.listener != nil {
                weakSelf!.listener!(weakSelf!.currentStatus);
            }
        }
        reachability.startListening();
    }
    
    
    // MARK: - Public
    public static let shareInstance:AJNetworkStatus = AJNetworkStatus();
    
    public var listener:((_ status:AJNetworkReachability) -> Void)? = nil;
    public var currentStatus:AJNetworkReachability = .unknown;
    
    public func canReachable() -> Bool {
        return self.reachability.isReachable;
    }
    
}
