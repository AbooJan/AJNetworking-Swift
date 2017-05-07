//
//  AJNetworkError.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation

public struct AJError:Swift.Error {
    public private(set) var code:Int = -9090;
    public private(set) var msg:String? = nil;
    
    static func defaultInit() -> AJError {
        let err = AJError(code: -9090, msg: "unkown error");
        return err;
    }
}
