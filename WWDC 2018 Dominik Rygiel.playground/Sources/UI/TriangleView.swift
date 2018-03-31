import UIKit

public class TriangleView: UIView {
    
    public var isReversed = false
    public private(set) var isFilled = false
    public private(set) var position: Position
    
    public var color: UIColor = .defaultColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var shouldUnhighlight: Bool {
        get {
            return isHighlighted && !isFilled
        }
    }
    
    public private(set) var isHighlighted = false {
        didSet {
            if !isHighlighted {
                color = .defaultColor
            }
        }
    }
    
    public init(color: UIColor = .defaultColor, position: Position) {
        self.color = color
        self.position = position
        super.init(frame: CGRect(x: 0, y: 0, width: GameConstants.size, height: GameConstants.size))
        let row = position.row
        let column = position.column
        if row % 2 == 0 && column % 2 == 1 || row % 2 == 1 && column % 2 == 0 {
            reversed(true)
        }
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.position = Position(row: 0, column: 0)
        super.init(coder: aDecoder)
        initialize()
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let leftBottomPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let rightBottomPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        let middleTopPoint = CGPoint(x: rect.maxX / 2, y: (rect.maxY - rect.maxY * sqrt(3.0) / 2))
        let radius: CGFloat = 3
        
        context.beginPath()
        context.move(to: leftBottomPoint)
        context.addArc(tangent1End: rightBottomPoint, tangent2End: middleTopPoint, radius: radius)
        context.addArc(tangent1End: middleTopPoint, tangent2End: leftBottomPoint, radius: radius)
        context.addArc(tangent1End: leftBottomPoint, tangent2End: rightBottomPoint, radius: radius)
        context.closePath()
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
    
    public func contains(point: CGPoint) -> Bool {
        return frame.contains(point)
    }
    
    public func canFill(isReversed: Bool) -> Bool {
        return self.isReversed == isReversed && !isFilled
    }
    
    public func fill(withColor color: UIColor) {
        self.color = color
        isFilled = true
    }
    
    public func unfill() {
        self.color = .defaultColor
        isFilled = false
        isHighlighted = false
    }
    
    public func highlight(withColor color: UIColor) {
        self.color = color
        isHighlighted = true
    }
    
    public func unhighlight() {
        self.color = .defaultColor
        isHighlighted = false
    }
    
    public func changePosition(to position: Position) {
        self.position = position
    }
    
    private func initialize() {
        backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    private func reversed(_ reversed: Bool) {
        isReversed = reversed
        let angle: CGFloat = isReversed ? .pi : 0
        transform = CGAffineTransform(rotationAngle: angle)
    }
}
