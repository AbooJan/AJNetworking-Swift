//
//  AJRequest.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/4/23.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import UIKit
import Alamofire


fileprivate typealias RequestSuccessHandler = ((_ jsonStr:String, _ fileUrl:URL?) -> Void);
fileprivate typealias RequestFailHandler = ((_ err:Error) -> Void);


//MARK: -
fileprivate class AJRequestManager: NSObject {
    
    fileprivate var manager:SessionManager? = nil;
    
    fileprivate class func shareInstance() -> AJRequestManager {
        return Static.shared;
    }
    
    fileprivate func setupManager(withBody body:AJRequestBody) {
        
        let config = URLSessionConfiguration.default;
        config.timeoutIntervalForRequest = body.timeout;
        config.timeoutIntervalForResource = body.timeout;
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders;
        
        self.manager = SessionManager(configuration:config);
    }
    

    private struct Static {
        static let shared:AJRequestManager = AJRequestManager();
    }
}

//MARK:-
/// Network Request Service
///     - S:Request Body
///     - E:Response Bean
public class AJRequest<S:AJRequestBody, E:AJBaseResponseBean>: NSObject {
    
    // MARK: Public
    
    public typealias RequestCallback = ((_ responseModel:E?, _ fileUrl:URL?, _ err:AJError? ) -> Void);
    public typealias ProgressCallback = ((_ progress:Progress) -> Void);
    
    /// send network request
    ///
    /// - Parameters:
    ///   - requestbody: network request body, it contain request requirement params
    ///   - callback: network reqeust callback info
    ///   - progress: upload or download request will callback progress
    public class func sendRequest(_ requestbody:S,
                                  callback:@escaping RequestCallback,
                                  progress:ProgressCallback? = nil ) {
        
        // network check
        guard AJNetworkStatus.shareInstance.canReachable() else {
            let err = AJError(code: -6666, msg: "network is disconnected")
            callback(nil, nil, err);
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
            
            callback(nil, nil, ajErr);
        }
        
        // handle success closure
        let handleSuccess:RequestSuccessHandler = { (jsonStr:String, fileUrl:URL?) in
            //Log
            print("\n###### RESPONSE ######");
            print("#SOURCE#: \(requestPath)")
            print("# JSON #: \(jsonStr)");
            print("############\n\n");
            
            //callback
            if let model = E.deserialize(from: jsonStr) {
                
                if requestbody.isSuccess(model.code) {
                    callback(model, fileUrl, nil);
                    
                }else{
                    callback(model, nil, AJError(code: Int(model.code)!, msg: model.msg));
                }
                
            }else{
                
                // download file will return nothing json
                if fileUrl != nil {
                    callback(nil, fileUrl, nil);
                    
                }else {
                    
                    let ajErr = AJError(code: -9090, msg: "json deserialize to model fail" );
                    callback(nil, nil, ajErr);
                }
            }
        }
        
        // init manager
        AJRequestManager.shareInstance().setupManager(withBody: requestbody);
        
        // filter request
        if let _ = requestbody.multipartFormData {
            self.upload(withBody: requestbody,
                        progress: progress,
                        success: handleSuccess,
                        fail: handleFailure);
            
        }else if let _ = requestbody.downloadFileDestination {
            self.download(withBody: requestbody,
                          progress: progress,
                          success: handleSuccess,
                          fail: handleFailure);
            
        }else{
            self.commonRequest(withBody: requestbody,
                               success: handleSuccess,
                               fail: handleFailure);
        }
    }
    
    
    // MARK: Private
    
    fileprivate class func commonRequest(withBody body:S,
                                         success:@escaping RequestSuccessHandler,
                                         fail:@escaping RequestFailHandler) {
        
        let convertParams = self.convertParams(withBody: body);
        
        let _ = AJRequestManager.shareInstance().manager?.request(convertParams.path, method: convertParams.method, parameters: body.params, encoding: convertParams.encoding, headers: body.headers).responseString { (response:DataResponse<String>) in
            
            // dismiss hub
            if body.hub != nil {
                AJNetworkConfig.shareInstance.hubHanlder?.dismissHub();
            }
            
            switch response.result {
            case .success(let jsonStr):
                success(jsonStr, nil);
                
            case .failure(let err):
                fail(err);
            }
        }
    }
    
    fileprivate class func upload(withBody body:S,
                                  progress:ProgressCallback? = nil,
                                  success:@escaping RequestSuccessHandler,
                                  fail:@escaping RequestFailHandler) {
        
        let multipart = body.multipartFormData!;
        let convertParams = self.convertParams(withBody: body);
        
        AJRequestManager.shareInstance().manager?.upload(multipartFormData: { (formData) in
            
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
            case .success(let request, _, let fileUrl):
                request.responseString(completionHandler: { (res:DataResponse<String>) in
                    switch res.result {
                    case .success(let jsonStr):
                        success(jsonStr, fileUrl);
                        
                    case .failure(let err):
                        fail(err);
                    }
                });
                request.uploadProgress(closure: { (pg:Progress) in
                    progress?(pg);
                });
                
            case .failure(let err):
                fail(err);
            }
        });
        
    }
    
    fileprivate class func download(withBody body:S,
                                    progress:ProgressCallback? = nil,
                                    success:@escaping RequestSuccessHandler,
                                    fail:@escaping RequestFailHandler) {
        
        let convertParams = self.convertParams(withBody: body);
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let doc:URL = URL(fileURLWithPath: body.downloadFileDestination!.filePath);
            let fileURL = doc.appendingPathComponent(body.downloadFileDestination!.fileName);
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]);
        }
        
        AJRequestManager.shareInstance().manager?.download(convertParams.path,
                                                           method: convertParams.method,
                                                           parameters: body.params,
                                                           encoding: convertParams.encoding,
                                                           headers: body.headers,
                                                           to:destination)
            .response(completionHandler: { (res:DefaultDownloadResponse) in
                if res.error == nil {
                    success("", res.destinationURL);
                }else{
                    fail(res.error!);
                }
                
            }).downloadProgress(closure: { (pg:Progress) in
                progress?(pg);
            })
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

