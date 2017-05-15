//
//  RequestBody.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/5/1.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation

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
