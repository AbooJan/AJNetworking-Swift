//
//  AJRequest.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import UIKit
import Alamofire

// MARK: -


/// Network Request Service
///     - S:Request Body
///     - E:Response Bean
public class AJRequest<S:AJRequestBody, E:AJBaseResponseBean>: NSObject {
    
    // MARK: - Public
    
    /// send network request
    ///
    /// - Parameters:
    ///   - requestbody: network request body, it contain request requirement params
    ///   - callback: network reqeust callback info
    ///   - responseModel: network request return data model
    ///   - err: network request fail error info
    public class func sendRequest(_ requestbody:S, callback:@escaping (_ responseModel:E?, _ err:AJError?) -> Void) {
        
        // network check
        guard AJNetworkStatus.shareInstance.canReachable() else {
            let err = AJError(code: -6666, msg: "network is disconnected")
            callback(nil, err);
            return;
        }
        
        let requestPath:String = packagePath(withRequestBody: requestbody);
        let encoding:ParameterEncoding = convertEncoding(withRequestBody: requestbody);
        let method:HTTPMethod = HTTPMethod(rawValue: requestbody.method.rawValue)!;
        
        // Log
        print("\n****** REQUEST ******");
        print("*METHOD*: \(requestbody.method.rawValue)");
        print("* PATH *: \(requestPath)");
        print("*PARAMS*: \(requestbody.params ?? [:])");
        print("************\n\n");
        
        //show hub
        if requestbody.hub != nil {
            AJNetworkConfig.shareInstance.hubHanlder?.showHub(tips: requestbody.hub);
        }
        
        
        //timeout
        let config = URLSessionConfiguration.default;
        config.timeoutIntervalForRequest = requestbody.timeout;
        
        let manager = SessionManager(configuration: config);
        
        let _ = manager.request(requestPath, method: method, parameters: requestbody.params, encoding: encoding, headers: requestbody.headers).responseString { (response:DataResponse<String>) in
                
                // dismiss hub
                if requestbody.hub != nil {
                    AJNetworkConfig.shareInstance.hubHanlder?.dismissHub();
                }
            
                switch response.result {
                case .success(let jsonStr):
                    //Log
                    print("\n###### RESPONSE ######");
                    print("#SOURCE#: \(requestPath)")
                    print("# JSON #: \(jsonStr)");
                    print("############\n\n");
                    
                    //callback
                    if let model = E.deserialize(from: jsonStr) {
                        
                        if requestbody.isSuccess(model.code) {
                            callback(model, nil);
                            
                        }else{
                            callback(model, AJError(code: Int(model.code)!, msg: model.msg));
                        }
                        
                    }else{
                        let ajErr = AJError(code: -9090, msg: "json deserialize to model fail" );
                        callback(nil, ajErr);
                    }
                    
                case .failure(let err):
                    //Log
                    let errDesc: Result<String> = .failure(err)
                    print("\n‼️‼️‼️ ERROR ‼️‼️‼️");
                    print("#error#: \(errDesc)");
                    print("‼️‼️‼️‼️‼️‼️\n\n");
                
                    //callback 
                    let nsErr = err as NSError;
                    
                    let errInfo = nsErr.userInfo;
                    let ajErr = AJError(code: nsErr.code, msg: errInfo["NSLocalizedDescription"] as? String );
                    callback(nil, ajErr);
                }
                
        }
        
    }
    
    
    // MARK: - Private
    fileprivate class func packagePath(withRequestBody body:S) -> String {
        
        assert(body.host.isEmpty == false, "please config network request host first at class `AJNetworkConfig`");
        
        assert(body.apiPath.isEmpty == false, "network request api can not be empty");
        
        let path = "\(body.scheme.rawValue)://\(body.host)/\(body.apiPath)";
        
        return path;
    }
    
    fileprivate class func convertEncoding(withRequestBody body:S) -> ParameterEncoding {
        
        switch body.serializationType {
            
        case .form:
            return URLEncoding.default;
            
        case .json:
            return JSONEncoding.default;
            
        case .propertyList:
            return PropertyListEncoding.default;
        }
        
    }
}

