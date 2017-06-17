# AJNetworking-Swift
A Network Framework basic on Alamofire and HandyJSON.
Swift version is `3.1`.


* ApiTest:https://github.com/AbooJan/BeegoDemo

---
## Usage

### Step1
Firstly you need use class `AJNetworkConfig` to define some global parameters, it is a singleton.

```
    /// global network request host path
    public var host:String? = nil;

    /// https request certificate password
    public var httpsCerPW:String? = nil;

    /// https request certificate bundle path
    public var httpsCerPath:String? = nil;

    /// custom hub delegate
    public var hubHanlder:AJHubPlugin? = nil;
```

### Step2
```
AJRequest<MultipartTestRequest, AJBaseCommonResponseBean<AJBaseBean>>.sendRequest(.uploadAvatar(avatar: #imageLiteral(resourceName: "test")), callback: { (res:AJBaseCommonResponseBean<AJBaseBean>?, fileUrl:URL?, err:AJError?) in
            
            if err == nil {
                print("🤖:"+(res?.toJSONString() ?? ""));
                print("#file#: \(fileUrl?.absoluteString ?? "")");
            }
            
        }) { (progress:Progress) in
            
            let percent:Double = Double(progress.completedUnitCount)/Double(progress.totalUnitCount);
            print("\(#line)-#progress#: \(percent)");
        }
```

* `AJRequest`  is in charge of network request, it has two generic params `<S:AJRequestBody, E:AJBaseResponseBean>`.

* `AJRequestBody`  is a protocal, it contains network request  params define . Parameter `apiPath` and `params` must be implemented, rest has default implementation.

* `AJBaseResponseBean` is a basic json serialize class, it also contain two sub basic class `AJBaseCommonResponseBean` and `AJBaseListResponseBean`. They has one generic parameter must inherit class `AJBaseBean`. They are all inherit protocol `HandyJSON`.


### Multipart Request
inherit protocol `AJRequestBody` , and turn `multipartFormData`, here is example:
```
    var multipartFormData:[FormData]? {
        
        switch self {
        case .uploadAvatar(let avatar):
            
            // if you upload file, you need to send mimeType
            let formData:FormData = FormData(data: UIImageJPEGRepresentation(avatar, 0.6)!, name: "avatar", mimeType:"image/jpeg");
            
            // if you need post other params, can use utf8 ecoding data
            let data:Data = "18090939282".data(using: .utf8)!;
            let param:FormData = FormData(data: data, name: "phone", mimeType: nil);
            
            return [formData, param];
        }
    }
```

### Download File Request
inherit protocol `AJRequestBody` , and turn `downloadFileDestination`, it return a tuple which contain two params, here is example:
```
    var downloadFileDestination:(filePath:String, fileName:String)? {
        
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let name:String = "avatar.jpeg";
        
        return (filePath:doc.absoluteString, fileName:name);
    }
```

---
## Thanks

* [Alamofire](https://github.com/Alamofire/Alamofire) 
* [HandyJSON](https://github.com/alibaba/HandyJSON)    

