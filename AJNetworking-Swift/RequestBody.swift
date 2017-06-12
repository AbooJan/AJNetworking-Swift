//
//  RequestBody.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/5/1.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum TestRequest {
    case login(phone:String, pw:String)
    case friends(userID:Int64)
    case user(userID:Int64)
}

extension TestRequest:AJRequestBody {
    
    var apiPath:String {
        switch self {
        case .login:
            return "login";
            
        case .friends:
            return "friends";
            
        case .user:
            return "user";
        }
    }
    
    var params:[String:Any]? {
        switch self {
        case .login(let phone, let pw):
            return ["phone":phone, "pw":pw];
            
        case .friends(let userID):
            return ["userID":userID];
            
        case .user(let userID):
            return ["userID":userID];
        }
    }
    
    var method:HttpMethod {
        switch self {
        case .login:
            return .post;
            
        case .friends:
            return .get;
            
        case .user:
            return .get;
        }
    }
    
    
    func isSuccess(_ code: String) -> Bool {
        if code == "111" {
            return true;
        }
        
        return false;
    }
    
    var timeout:TimeInterval {
        return 15.0;
    }
}

//MARK:---
enum MultipartTestRequest {
    /// upload with fileData
    case uploadAvatar(avatar:UIImage)
    /// upload with fileUrl
    case uploadLogo(logo:URL)
}

extension MultipartTestRequest:AJRequestBody {
    
    var apiPath:String {
        return "uploadAvatar"
    }
    
    var params:[String:Any]? {
        return [:];
    }
 
    var multipartFormData:[AJFormData]? {
        
        switch self {
        case .uploadAvatar(let avatar):
            
            let formData:AJFormData = AJFormData(data: UIImageJPEGRepresentation(avatar, 0.6)!, name: "avatar", mimeType:"image/jpeg");
            
            let data:Data = "18090939282".data(using: .utf8)!;
            let param:AJFormData = AJFormData(data: data, name: "phone", mimeType: nil);
            
            return [formData, param];
            
            
        case .uploadLogo(let logo):
            
            let formData:AJFormData = AJFormData(fileUrl:logo, name: "avatar", mimeType:"image/jpeg");
            
            let data:Data = "18090939282".data(using: .utf8)!;
            let param:AJFormData = AJFormData(data: data, name: "phone", mimeType: nil);
            
            return [formData, param];
        }
    }
    
    var headers:[String:String]? {
        return ["Content-Type":"multipart/form-data"];
    }
    
    var timeout: TimeInterval {
        return 20.0;
    }
    
    func isSuccess(_ code: String) -> Bool {
        if code == "111" {
            return true;
        }
        
        return false;
    }

}
