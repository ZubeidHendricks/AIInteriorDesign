import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// A design style. On-device we apply the style's *mood* (color grade) to a room
/// photo; the full generative redesign is a Remote-service upgrade.
struct DesignStyle: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let isPremium: Bool
    // Color-grade parameters that evoke the style's mood.
    let saturation: Float
    let contrast: Float
    let warmth: CGFloat        // target neutral temperature (K); <6500 warmer

    static let all: [DesignStyle] = [
        .init(id: "scandi", name: "Scandinavian", icon: "snowflake", isPremium: false, saturation: 0.92, contrast: 1.05, warmth: 7000),
        .init(id: "cozy", name: "Cozy", icon: "flame", isPremium: true, saturation: 1.08, contrast: 1.04, warmth: 5200),
        .init(id: "industrial", name: "Industrial", icon: "wrench.and.screwdriver", isPremium: true, saturation: 0.78, contrast: 1.12, warmth: 6200),
        .init(id: "luxe", name: "Luxe", icon: "sparkles", isPremium: true, saturation: 1.12, contrast: 1.08, warmth: 5800),
    ]
}

enum InteriorError: Error { case badImage, notConfigured }

protocol InteriorDesignService {
    func apply(style: DesignStyle, to image: UIImage) async throws -> UIImage
}

/// On-device style-mood grading — a real, instant preview of how a room *feels*
/// in a given style. Full "redesign the room" generation goes behind Remote.
struct OnDeviceInteriorService: InteriorDesignService {
    private let context = CIContext()

    func apply(style: DesignStyle, to image: UIImage) async throws -> UIImage {
        try await Task.detached(priority: .userInitiated) {
            try Self.render(style: style, image: image, context: context)
        }.value
    }

    private static func render(style: DesignStyle, image: UIImage, context: CIContext) throws -> UIImage {
        guard let cg = image.normalizedUp().cgImage else { throw InteriorError.badImage }
        var ci = CIImage(cgImage: cg)
        let extent = ci.extent

        let controls = CIFilter.colorControls()
        controls.inputImage = ci
        controls.saturation = style.saturation
        controls.contrast = style.contrast
        ci = controls.outputImage ?? ci

        let temp = CIFilter.temperatureAndTint()
        temp.inputImage = ci
        temp.neutral = CIVector(x: 6500, y: 0)
        temp.targetNeutral = CIVector(x: style.warmth, y: 0)
        ci = temp.outputImage ?? ci

        ci = ci.cropped(to: extent)
        guard let result = context.createCGImage(ci, from: extent) else { throw InteriorError.badImage }
        return UIImage(cgImage: result)
    }
}

/// Production redesign (generative). Wire your endpoint here.
struct RemoteInteriorService: InteriorDesignService {
    let apiKey: String
    func apply(style: DesignStyle, to image: UIImage) async throws -> UIImage {
        throw InteriorError.notConfigured
    }
}

extension UIImage {
    func normalizedUp() -> UIImage {
        if imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
