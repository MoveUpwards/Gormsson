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
            }, didReadyHandler: {
                self?.aNumber = 3
            }, didDisconnectHandler: { _, _ in
                self?.aNumber = 4
            })
        }
        weakGormsson?.set({ [weak self] _, _ in
            self?.aNumber = 5 // Replace 4
        })

        weakGormsson = nil
        XCTAssertNil(weakGormsson)

        var strongGormsson: Gormsson? = Gormsson()
        strongGormsson?.scan { peripheral, _ in
            self.aNumber = 1
            strongGormsson?.connect(peripheral, success: { _ in
                self.aNumber = 2
            }, didReadyHandler: {
                self.aNumber = 3
            }, didDisconnectHandler: { _, _ in
                self.aNumber = 4
            })
        }
        strongGormsson?.set({ _, _ in
            self.aNumber = 5 // Replace 4
        })

        strongGormsson = nil
        XCTAssertNil(strongGormsson)
    }
}
