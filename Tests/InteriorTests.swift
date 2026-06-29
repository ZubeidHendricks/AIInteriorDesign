import XCTest
import UIKit
// InteriorService.swift compiled into this test target.

final class InteriorTests: XCTestCase {
    private func image(_ s: CGFloat = 400) -> UIImage {
        let f = UIGraphicsImageRendererFormat.default(); f.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: s, height: s), format: f).image { c in
            UIColor.brown.setFill(); c.fill(CGRect(x: 0, y: 0, width: s, height: s))
        }
    }

    func testStyleCatalog() {
        XCTAssertGreaterThanOrEqual(DesignStyle.all.count, 4)
        XCTAssertFalse(DesignStyle.all[0].isPremium)   // first style is free
    }

    func testApplyStyleProducesImage() async throws {
        let out = try await OnDeviceInteriorService().apply(style: DesignStyle.all[0], to: image())
        XCTAssertEqual(out.cgImage?.width, image().cgImage?.width)
    }
}
