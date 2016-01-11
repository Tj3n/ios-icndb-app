//
//  Network.swift
//  Test1
//
//  Created by Tien Nhat Vu on 1/8/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//
import Foundation
import Moya

// MARK: - Provider setup

let NetworkProvider = MoyaProvider<Network>()

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public enum Network {
    case Joke(String, String, [String], [String])
    case Category
}

extension Network: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://api.icndb.com")! }
    
    public var path: String {
        switch self {
        case .Category:
            return "/categories"
        case .Joke(let firstName, let lastName, let limit, let exclude):
            return "\(checkName(firstName, lastName: lastName))\((checkSubParam(limit, exclude: exclude)).stringByReplacingOccurrencesOfString("\"", withString: ""))"
        }
    }
    
    func checkName(firstName: String, lastName: String) -> String {
        if firstName.characters.count == 0 && lastName.characters.count == 0 {
            return "jokes/random?"
        } else if firstName.characters.count == 0 && lastName.characters.count != 0 {
            return "jokes/random?firstName=\(firstName.URLEscapedString)"
        } else if firstName.characters.count != 0 && lastName.characters.count == 0 {
            return "jokes/random?lastName=\(lastName.URLEscapedString)"
        } else {
            return "jokes/random?firstName=\(firstName.URLEscapedString)&lastName=\(lastName.URLEscapedString)"
        }
    }
    
    func checkSubParam(limit: [String], exclude: [String]) -> String {
        if limit.count == 0 && exclude.count == 0 {
            return ""
        } else if limit.count != 0 && exclude.count == 0 {
            return "&limitTo=\(limit)"
        } else if limit.count == 0 && exclude.count != 0 {
            return "&exclude=\(exclude)"
        } else {
            return "&limitTo=\(limit)&exclude=\(exclude)"
        }
    }

    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters: [String: AnyObject]? {
//        switch self {
//        case .UserRepositories(_):
//            return ["sort": "pushed"]
//        default:
            return nil
//        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Category:
            return "{ \"type\": \"success\", \"value\": [ ] }".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Joke(_,_,_,_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

public func url(route: TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}
