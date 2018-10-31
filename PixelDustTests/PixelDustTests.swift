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

    func testConstruction() {
        let comparator = ImageComparator()
        XCTAssertFalse(comparator.compare())
    }

    func testSetImage() {
        guard let uiImage1 = UIImage(named: "image1"),
            let uiImage2 = UIImage(named: "image1-different") else {
                XCTFail()
                return
        }
        
        let comparator = ImageComparator()
        comparator.setImage(uiImage1, image2: uiImage2)

        XCTAssertFalse(comparator.compare())
        XCTAssertGreaterThan(comparator.diffFactor, 0)
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testDifferentImages() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image1-different")!)
        XCTAssertFalse(comparator.compare());
        XCTAssertGreaterThan(comparator.diffFactor, 0.0)
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testAmplifiedDiff() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image1-different")!)
        XCTAssertFalse(comparator.compare());
        XCTAssertGreaterThan(comparator.diffFactor, 0.0)
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testImageSameSame() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image1-same")!)
        XCTAssertTrue(comparator.compare());
        XCTAssertEqual(0.0, comparator.diffFactor)
        add(XCTAttachment(image: comparator.getDiffImage()))
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testOnePixelDiff() {
        let comparator = ImageComparator(image: UIImage(named: "white-first-pixel-black")!, image2: UIImage(named: "white")!)
        XCTAssertFalse(comparator.compare())
        XCTAssertGreaterThan(comparator.diffFactor, 0.0)
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testDifferentDimensions() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "sideways")!)
        XCTAssertFalse(comparator.compare())
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }

    func testSetImageAgain() {
        let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image1-same")!)
        XCTAssertTrue(comparator.compare())
        add(XCTAttachment(image: comparator.getDiffImage(true)))
        
        comparator.setImage(UIImage(named: "image1")!, image2: UIImage(named: "sideways")!)
        XCTAssertFalse(comparator.compare())
        add(XCTAttachment(image: comparator.getDiffImage(true)))
    }
}
