//
//  BaseResponseBean.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/25.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation
import HandyJSON

open class AJBaseResponseBean:NSObject,HandyJSON {
    public var code:String = "0";
    public var msg:String = "";
    
    public required override init() {}
}

open class AJBaseBean:NSObject,HandyJSON {
    public required override init() {}
}


// MARK: -
open class AJBaseListResponseBean<T:AJBaseBean>:AJBaseResponseBean {
    public var data:Array<T> = Array();
}


// MARK: -
open class AJBaseCommonResponseBean<T:AJBaseBean>:AJBaseResponseBean {
    public var data:T?
}
