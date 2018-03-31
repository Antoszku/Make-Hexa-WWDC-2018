import UIKit

public struct GameConstants {
    public static let size: CGFloat = 56
    public static var yPosition: Int = {
        return Int(0.99 * size)
    }()
    
    public static var xPosition: Int = {
        return Int(0.57 * size)
    }()
    
    public static var padding: CGFloat = {
        return CGFloat(Int(0.1 * size))
    }()
}


public var positionToTriangle = [Position: TriangleView]()
