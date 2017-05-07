# AJNetworking-Swift
A Network Framework basic on Alamofire and EVReflection.
Swift version is `3.1`.

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
AJRequest<TestRequest, AJBaseCommonResponseBean<LoginResponseBean>>.sendRequest(.login(account: "13622823688", pw: "666666")) { (model:AJBaseCommonResponseBean<LoginResponseBean>?, err:AJError?) in
            
            if err == nil {
                let code = model?.code;
                let msg = model?.msg;
                let data = model?.data;
                let userid = data?.userId;
                
                print(userid);
            }
        }
```

* `AJRequest`  is in charge of network request, it has two generic params `<S:AJRequestBody, E:AJBaseResponseBean>`.

* `AJRequestBody`  is a protocal, it contains network request  params define . Parameter `apiPath` and `params` must be implemented, rest has default implementation.

* `AJBaseResponseBean` is a basic json serialize class, it also contain two sub basic class `AJBaseCommonResponseBean` and `AJBaseListResponseBean`. They has one generic parameter must inherit class `AJBaseBean`. They are all inherit class `EVNetworkingObject`.

---
## Thanks

* [Alamofire](https://github.com/Alamofire/Alamofire) 
* [EVReflection](https://github.com/evermeer/EVReflection)    

