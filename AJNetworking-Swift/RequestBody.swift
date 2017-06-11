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
    case login(account:String, pw:String)
    case news(id:String, time:String)
}

extension TestRequest:AJRequestBody {
    
    var apiPath:String {
        switch self {
        case .login:
            return "login";
            
        case .news:
            return "news";
        }
    }
    
    var params:[String:Any]? {
        switch self {
        case .login(let account, let pw):
            return ["account":account, "pw":pw];
            
        case .news(let id, let time):
            return ["userId":id, "dateTime":time];
            
        }
    }
    
    
    func isSuccess(_ code: String) -> Bool {
        if code == "1" {
            return true;
        }
        
        return false;
    }
    
    var timeout:TimeInterval {
        return 10.0;
    }
}

//MARK:---
enum MultipartTestRequest {
    case uploadAvatar(avatar:UIImage)
}

extension MultipartTestRequest:AJRequestBody {
    
    var apiPath:String {
        return "test/uploadAvatar"
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
        }
    }
    
    var method:HttpMethod {
        return .post;
    }
    
    var headers:[String:String]? {
        return ["Content-Type":"multipart/form-data"];
    }
    
    func isSuccess(_ code: String) -> Bool {
        if code == "111" {
            return true;
        }
        
        return false;
    }
    
    var timeout:TimeInterval {
        return 20.0;
    }
}
