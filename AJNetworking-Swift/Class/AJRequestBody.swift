//
//  AJRequestBody.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation
import Alamofire

//MARK: -
public struct FormData {
    var data:Data;
    var name:String;
    
    ///noly file need mime type
    var mimeType:String?;
    
    func fileName() -> String {
        if let tmp = mimeType?.components(separatedBy: "/") {
            if tmp.count == 2 {
                if let fileType = tmp.last {
                    return name+".\(fileType)";
                }
            }
        }
        
        return name;
    }
}

// MARK: - Enum
public enum HttpMethod:String {
    case get     = "GET"
    case post    = "POST"
}

public enum HttpScheme:String {
    case http = "http"
    case https = "https"
}

public enum HttpRequestSerialization {
    /// Content-Type:application/x-www-form-urlencoded
    case form
    /// Content-Type:application/json
    case json
    /// Content-Type:application/x-plist
    case propertyList
}

// MARK: - AJRequestBody

public protocol AJRequestBody {
    
    /// network request scheme, default is http
    var scheme:HttpScheme {get};
    
    /// network request host, default will read your host global config
    var host:String {get};
    
    /// network request api path
    var apiPath:String {get};
    
    /// network request method, default is GET
    var method:HttpMethod {get};
    
    /// network request params
    var params:[String:Any]? {get};
    
    /// network request header, default is nil
    var headers:[String:String]? {get};
    
    /// network request timeout, default is 30 seconds
    var timeout:TimeInterval {get} ;
    
    /// network request serialization type, default is form
    var serializationType:HttpRequestSerialization {get};
    
    /// multipart form data request
    var multipartFormData:[FormData]? {get};
    
    /// the progress tips show when network request start, nil will not show
    var hub:String? {get};
    
    
    /// check response is server success result
    func isSuccess(_ code:String) -> Bool ;
}

// MARK: - Default Config
extension AJRequestBody {
    
    var scheme:HttpScheme {
        return .http;
    }
    
    var host:String {
        let configHost = AJNetworkConfig.shareInstance.host;
        assert((configHost != nil) && (configHost?.isEmpty == false), "please config network request host first at class `AJNetworkConfig`");
        return configHost!;
    }
    
    var method:HttpMethod {
        return .get;
    }
    
    var headers:[String:String]? {
        return nil;
    }
    
    var timeout:TimeInterval {
        return 30.0;
    }
    
    var serializationType:HttpRequestSerialization {
        return .form;
    }
    
    var multipartFormData:[FormData]? {
        return nil;
    }
    
    var hub:String? {
        return nil;
    }
    
}


