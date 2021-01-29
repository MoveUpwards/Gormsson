//
//  GormssonTests.swift
//  GormssonTests
//
//  Created by Mac on 05/11/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import XCTest
@testable import Gormsson
@testable import Nevanlinna

class GormssonTests: XCTestCase {
    private var aNumber = 0

    // Test block's variables to be weak
    func testWeakBlock() {
        var weakGormsson: Gormsson? = Gormsson()
        weakGormsson?.scan { [weak self] peripheral, _ in
            self?.aNumber = 1
            weakGormsson?.connect(peripheral, success: { _ in
                self?.aNumber = 2
            }, failure: { _, _ in
                self?.aNumber = 3
            }, didReadyHandler: {
                self?.aNumber = 4
            }, didDisconnectHandler: { _, _ in
                self?.aNumber = 5
            })
        }

        weakGormsson = nil
        XCTAssertNil(weakGormsson)

        var strongGormsson: Gormsson? = Gormsson()
        strongGormsson?.scan { peripheral, _ in
            self.aNumber = 1
            strongGormsson?.connect(peripheral, success: { _ in
                self.aNumber = 2
            }, failure: { _, _ in
                self.aNumber = 3
            }, didReadyHandler: {
                self.aNumber = 4
            }, didDisconnectHandler: { _, _ in
                self.aNumber = 5
            })
        }

        strongGormsson = nil
        XCTAssertNil(strongGormsson)
    }
}
