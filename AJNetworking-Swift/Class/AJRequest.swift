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

typealias RequestSuccessHandler = ((_ jsonStr:String) -> Void)
typealias RequestFailHandler = ((_ err:Error) -> Void)

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
        
        let requestPath:String = self.packagePath(withRequestBody: requestbody);
        
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
    
        
        // handle failure closure
        let handleFailure:RequestFailHandler = { (err:Error) in
            
            //callback
            let nsErr = err as NSError;
            
            let errInfo = nsErr.userInfo;
            let ajErr = AJError(code: nsErr.code, msg: errInfo["NSLocalizedDescription"] as? String );
            
            //Log
            print("\n‼️‼️‼️ ERROR ‼️‼️‼️");
            print("#error#: \(errInfo)");
            print("‼️‼️‼️‼️‼️‼️\n\n");
            
            callback(nil, ajErr);
        }
        
        // handle success closure
        let handleSuccess:RequestSuccessHandler = { (jsonStr:String) in
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
        }
        
        // filter request
        if let _ = requestbody.multipartFormData {
            self.upload(withBody: requestbody, success: handleSuccess, fail: handleFailure);
            
        }else{
            self.commonRequest(withBody: requestbody, success: handleSuccess, fail: handleFailure);
        }
    }
    
    
    // MARK: - Private
    
    fileprivate class func commonRequest(withBody body:S,
                                         success:@escaping RequestSuccessHandler,
                                         fail:@escaping RequestFailHandler) {
        
        //timeout
        let config = URLSessionConfiguration.default;
        config.timeoutIntervalForRequest = body.timeout;
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        let manager = SessionManager(configuration: config);
        
        let convertParams = self.convertParams(withBody: body);
        
        let _ = manager.request(convertParams.path, method: convertParams.method, parameters: body.params, encoding: convertParams.encoding, headers: body.headers).responseString { (response:DataResponse<String>) in
            
            // dismiss hub
            if body.hub != nil {
                AJNetworkConfig.shareInstance.hubHanlder?.dismissHub();
            }
            
            switch response.result {
            case .success(let jsonStr):
                success(jsonStr);
                
            case .failure(let err):
                fail(err);
            }
        }
    }
    
    fileprivate class func upload(withBody body:S,
                                  success:@escaping RequestSuccessHandler,
                                  fail:@escaping RequestFailHandler) {
        
        let multipart = body.multipartFormData!;
        let convertParams = self.convertParams(withBody: body);
        
        Alamofire.upload(multipartFormData: { (formData) in
            
            // append form data
            for form in multipart {
                
                if let mimeType = form.mimeType {
                    
                    if let data = form.data {
                        formData.append(data, withName: form.name, fileName: form.fileName(), mimeType: mimeType);
                    }else if let url = form.fileUrl {
                        formData.append(url, withName: form.name, fileName: form.fileName(), mimeType: mimeType);
                    }else {
                        assert(false, "there is no multipartFormData");
                    }
                    
                }else{
                    if let data = form.data {
                        formData.append(data, withName: form.name);
                    }else if let url = form.fileUrl {
                        formData.append(url, withName: form.name);
                    }else {
                        assert(false, "there is no multipartFormData");
                    }
                }
            }
            
        }, to: convertParams.path, headers: body.headers, encodingCompletion: { (result:SessionManager.MultipartFormDataEncodingResult) in
            
            // dismiss hub
            if body.hub != nil {
                AJNetworkConfig.shareInstance.hubHanlder?.dismissHub();
            }
            
            switch result {
            case .success(let request, _, _):
                request.responseString(completionHandler: { (res:DataResponse<String>) in
                    switch res.result {
                    case .success(let jsonStr):
                        success(jsonStr);
                        
                    case .failure(let err):
                        fail(err);
                    }
                });
                
            case .failure(let err):
                fail(err);
            }
        });
        
    }
    
    //MARK: utils
    fileprivate class func convertParams(withBody body:S) -> (path:String, encoding:ParameterEncoding, method:HTTPMethod) {
        let requestPath:String = packagePath(withRequestBody: body);
        let encoding:ParameterEncoding = convertEncoding(withRequestBody: body);
        let method:HTTPMethod = HTTPMethod(rawValue: body.method.rawValue)!;
        
        return (requestPath, encoding, method);
    }
    
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

