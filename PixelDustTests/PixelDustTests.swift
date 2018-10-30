//
//  PixelDustTests.swift
//  PixelDustTests
//
//  Created by Kain Osterholt on 10/27/18.
//  Copyright © 2018 Kain Osterholt. All rights reserved.
//

import XCTest
@testable import PixelDust

class PixelDustTests: XCTestCase {

    func testBlackAndWhite() {
        let comparator = ImageComparator(image: UIImage(named: "black")!, image2: UIImage(named: "white")!)
        self.measure {
            XCTAssertFalse(comparator.compare());
            add(XCTAttachment(image: comparator.getDiffImage()))
            add(XCTAttachment(image: comparator.getDiffImage(true)))
        }

        XCTAssertGreaterThan(comparator.getDiffFactor(), 0.0)
    }

    func testImageSameSame() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image1-same")!)

        self.measure {
            XCTAssertTrue(comparator.compare());
        }
        XCTAssertEqual(0.0, comparator.getDiffFactor())

        add(XCTAttachment(image: comparator.getDiffImage()))
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testOnePixelDiff() {
            let comparator = ImageComparator(image: UIImage(named: "white-first-pixel-black")!, image2: UIImage(named: "white")!)
            XCTAssertFalse(comparator.compare())
            XCTAssertGreaterThan(comparator.getDiffFactor(), 0.0)
    }
}
