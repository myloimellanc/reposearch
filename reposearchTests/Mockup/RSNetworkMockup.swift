//
//  RSNetworkMockup.swift
//  reposearchTests
//
//  Created by mellancmyloi on 2022/04/26.
//

#if TEST

import Foundation
import RxSwift


final class RSNetworkMockup {
    
}


extension RSNetworkMockup: RSNetworkInterface {
    func urlRequest(_ url: RSURLConvertible,
                    _ method: RSHTTPMethod,
                    parameters: Dictionary<String, Any>?,
                    headers: Dictionary<String, String>?) -> Single<Data> {
        for apiURL in RSAPIURL.allCases {
            if url as? String == apiURL.url, let responseMockup = apiURL.responseMockup(method: method) {
                return .just(responseMockup)
            }
        }
        
        return .error(RSError.http(500))
    }
}

#endif
