//
//  BaseResponseBean.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/25.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation
import EVReflection


open class AJBaseResponseBean:EVNetworkingObject {
    public var code:String = "0";
    public var msg:String = "";
}

open class AJBaseBean:EVNetworkingObject {
    //
}


// MARK: -
open class AJBaseListResponseBean<T:AJBaseBean>:AJBaseResponseBean {
    public var data:Array<T> = Array();
    
    override open func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "data" {
            data = value as! Array<T>;
        }
    }
    
    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "data") {
            data = value as! Array<T>;
        }
    }
    
    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}


// MARK: -
open class AJBaseCommonResponseBean<T:AJBaseBean>:AJBaseResponseBean {
    public var data:T?
    
    override open func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "data" {
            data = value as? T;
        }
    }
    
    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "data") {
            data = value as? T
        }
    }
    
    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}
