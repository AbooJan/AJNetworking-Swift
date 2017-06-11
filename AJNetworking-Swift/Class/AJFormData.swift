//
//  AJFormData.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/6/11.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import Foundation

public struct AJFormData {
    
    private(set) var data:Data?;
    private(set) var fileUrl:URL?;
    private(set) var name:String;
    ///noly file need mime type
    private(set) var mimeType:String?;
    
    init(data:Data, name:String, mimeType:String? = nil) {
        self.data = data;
        self.name = name;
        self.mimeType = mimeType;
    }
    
    init(fileUrl:URL, name:String, mimeType:String? = nil) {
        self.fileUrl = fileUrl;
        self.name = name;
        self.mimeType = mimeType;
    }
    
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
