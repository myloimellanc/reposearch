//
//  APITests.swift
//  reposearchTests
//
//  Created by mellancmyloi on 2022/04/26.
//

import Foundation
import XCTest
import RxSwift
@testable import reposearch


class APITests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testAPIs() throws {
        let apiVoids: [Single<Void>] = [
            RSAPIFactory.instance.searchRepositories(text: "")
                .map { _ in () }
        ]
        
        let tuples = apiVoids.map { single -> (Disposable, XCTestExpectation) in
            let expectation = XCTestExpectation()
            let disposable = single
                .subscribe(onSuccess: {
                    expectation.fulfill()
                    
                }, onFailure: { error in
                    XCTFail(error.localizedDescription)
                })
            
            return (disposable, expectation)
        }
        
        let disposables = tuples.map { $0.0 }
        let expectations = tuples.map { $0.1 }
        
        defer {
            disposables.forEach { $0.dispose() }
        }
        
        let timeoutInterval = RSNetworkTimeoutInterval * Double(apiVoids.count)
        wait(for: expectations, timeout: timeoutInterval)
    }
}
