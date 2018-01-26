# CodableAPI

[![CI Status](http://img.shields.io/travis/mcdappdev/CodableAPI.svg?style=flat)](https://travis-ci.org/mcdappdev/CodableAPI)
[![Version](https://img.shields.io/cocoapods/v/CodableAPI.svg?style=flat)](http://cocoapods.org/pods/CodableAPI)
[![License](https://img.shields.io/cocoapods/l/CodableAPI.svg?style=flat)](http://cocoapods.org/pods/CodableAPI)
[![Platform](https://img.shields.io/cocoapods/p/CodableAPI.svg?style=flat)](http://cocoapods.org/pods/CodableAPI)

## Motivation
This library is an opinionated way to handle making API requests and receiving responses in a Codable format. Please feel free to fork this project and make changes as you see fit, but note that every element of the existing protocol is extensible and customizable. 

## Installation

CodableAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CodableAPI'
```

## Usage

### Declaring a Request model 
Every time a request is made, that request needs an object. For example, 

```swift
struct LoginRequest: APIRequestRepresentable {
    //specify a Codable type that you want the response parsed into 
    typealias ResponseType = User

    //*optionally* specify an error type that you want any errors parsed into
    //if this is not specified, `GenericError` will be returned for any errors.
    //This may not work with your error responses - please set accordingly.
    typealias ErrorType = MyErrorType

    //the request's method
    var method: CodableAPI.HTTPRequestType = .post
    
    //the url of the request
    func url() -> String {
        return "your_url_here"
    }
}
```

We also need to create a model to hold the login information:

```swift
struct Login: Parameters {
    var email: String
    var password: String
}
```

Then, in your controller, do the following: 

```swift
let loginRequest = Login(email: "email@email.com", password: "secret password")
let successHandler: ((User?) -> Void) = { user in
    //handle the success
}

let errorHandler: ((Codable?) -> Void) = { error in
    //handle the error
}

LoginRequest().request(parameters: loginRequest, success: successHandler, error: errorHandler)
```

And that's it! Enjoy the type safe nature of Swift in all of its glory. 

### Headers
You can implement a `headers()` function in `APIRequestRepresentable` models. This will add the headers to the request. If none are added, `Content-Type: application/json` is set automatically.

### Custom Decoder
You can also implement a `jsonDecoder()` function in `APIRequestRepresentable` models. This is useful if you need to set properties like `dateDecodingStrategy`. If not implemented, a default `JSONDecoder()` instance is returned. 

## Author

Slate Solutions, Inc. 

## License

CodableAPI is available under the MIT license. See the LICENSE file for more info.
