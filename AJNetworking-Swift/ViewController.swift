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
    
    
    @IBAction func action3BtnClick(_ sender: Any) {
        test3();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func test3() {
        
        AJRequest<MultipartTestRequest, AJBaseCommonResponseBean<AJBaseBean>>.sendRequest(.uploadAvatar(avatar: #imageLiteral(resourceName: "test"))) { (res, err) in
            if err == nil {
                print(res ?? "");
            }
        }
    }
    
    func test2() {
        
        AJRequest<TestRequest, AJBaseListResponseBean<ArticleResponseBean>>.sendRequest(.news(id: "1001", time: "20170501")) { (model:AJBaseListResponseBean<ArticleResponseBean>?, err:AJError?) in

            if err == nil {
                let code = model?.code;
                let msg = model?.msg;
                let data = model?.data;
                let news1 = data?.first;
                let title = news1?.title;

                print(news1);
            }else {
                print(model?.msg ?? "");
            }
        }
        
    }


    func test1() {
        
        AJRequest<TestRequest, AJBaseCommonResponseBean<LoginResponseBean>>.sendRequest(.login(account: "13622823688", pw: "666666")) { (model:AJBaseCommonResponseBean<LoginResponseBean>?, err:AJError?) in

            if err == nil {
                let code = model?.code;
                let msg = model?.msg;
                let data = model?.data;
                let userid = data?.userId;

                print(userid);
            }
        }
        
    }
}

// MARK: -

class LoginResponseBean:AJBaseBean {
    var userId:String?
    var name:String?
    var age:Int = 0;
    var gender:String?
    var job:String?
}

class ArticleResponseBean:AJBaseBean {
    var title:String?
    var content:String?
    var author:String? 
}


