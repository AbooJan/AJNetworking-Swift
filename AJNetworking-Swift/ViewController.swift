//
//  ViewController.swift
//  AJNetworking-Swift
//
//  Created by aboojan on 2017/3/25.
//  Copyright © 2017年 AbooJan. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    
    @IBAction func action1BtnClick(_ sender: Any) {
        multipartRequest1();
    }
    
    @IBAction func action2BtnClick(_ sender: Any) {
        multipartRequest2();
    }
    
    @IBAction func action3BtnClick(_ sender: Any) {
        getRequest1();
    }
    
    @IBAction func action31BtnClick(_ sender: Any) {
        getRequest2()
    }
    
    
    @IBAction func action4BtnClick(_ sender: Any) {
        postRequest();
    }
    
    @IBAction func action5BtnClick(_ sender: Any) {
        downRequest();
    }
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func multipartRequest1() {
        
        AJRequest<MultipartTestRequest, AJBaseCommonResponseBean<AJBaseBean>>.sendRequest(.uploadAvatar(avatar: #imageLiteral(resourceName: "test")), callback: { (res:AJBaseCommonResponseBean<AJBaseBean>?, fileUrl:URL?, err:AJError?) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
                print("#file#: \(fileUrl?.absoluteString ?? "")");
            }
            
        }) { (progress:Progress) in
            
            let percent:Double = Double(progress.completedUnitCount)/Double(progress.totalUnitCount);
            print("\(#line)-#progress#: \(percent)");
        }
        
    }
    
    func multipartRequest2() {
        let path:String = Bundle.main.path(forResource: "logo", ofType: ".jpeg")!;
        let fileUrl:URL = URL(fileURLWithPath: path);
        
        AJRequest<MultipartTestRequest, AJBaseCommonResponseBean<AJBaseBean>>.sendRequest(.uploadLogo(logo: fileUrl), callback: { (res, fileUrl, err) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
                print("#file#: \(fileUrl?.absoluteString ?? "")");
            }
            
        }) { (pg:Progress) in
            
            let percent:Double = Double(pg.completedUnitCount)/Double(pg.totalUnitCount);
            print("\(#line)-#progress#: \(percent)");
        }
        
    }
    
    func getRequest1() {
        
        AJRequest<TestRequest, AJBaseCommonResponseBean<UserBean>>.sendRequest(.user(userID: 123456789), callback: {(res, _, err) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
            }
        });
    }
    
    func getRequest2() {
        
        AJRequest<TestRequest, AJBaseListResponseBean<UserBean>>.sendRequest(.friends(userID: 8384783783), callback: { (res, _, err) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
            }
            
        });
        
    }
    
    func postRequest() {
        
        AJRequest<TestRequest, AJBaseCommonResponseBean<UserBean>>.sendRequest(.login(phone: "13899896929", pw: "666666"), callback:{ (res, _, err) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
            }
            
        });
    }
    
    func downRequest() {
        AJRequest<DownRequesst, AJBaseResponseBean>.sendRequest(.avatar(userId: "1928373839"), callback: { (res, fileUrl, err) in
            
            if err == nil {
                print("#DOWN-FINISH#: \(fileUrl)");
            }
            
        }) { (progress:Progress) in
            
            let percent = Double(progress.completedUnitCount)/Double(progress.totalUnitCount);
            print("#DOWN#: \(percent)");
        }
    }

}

// MARK: -

class UserBean:AJBaseBean {
    var ID:Int64 = 0
    var name:String = ""
    var age:Int = 0
    var gender:Int = 0
    var height:Double = 0.0
    
    required init() {
        //
    }
}



