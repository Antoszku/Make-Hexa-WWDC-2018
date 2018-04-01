import UIKit

public class Figure: UIView {
    
    public var triangles = [TriangleView]()
    public let color: UIColor
    
    public var initialTriangle: TriangleView {
        get {
            return triangles[0]
        }
    }
    
    private let triangleCount: Int
    private let rotation = [0, CGFloat.pi / 3, CGFloat.pi * 2 / 3, CGFloat.pi, CGFloat.pi * 4 / 3, CGFloat.pi * 5 / 3]
    private var rotationIndex = 0
    var initialPosition = Position(row: 0, column: 0)
    private let trianglePositions = [
        Position(row: 0, column: 0),
        Position(row: 0, column: 1),
        Position(row: 0, column: 2),
        Position(row: 1, column: 2),
        Position(row: 1, column: 1),
        Position(row: 1, column: 0)
    ]
    
    public func nextPosition(of triangle: TriangleView) -> Position {
        var index = trianglePositions.index(of: triangle.position)!
        index += 1
        if index > 5 {
            index = 0
        }
        return trianglePositions[index]
    }
    
    public init(trianglesColor: UIColor, forTriangleCount triangleCount: Int) {
        self.triangleCount = triangleCount
        self.color = trianglesColor
        super.init(frame: .zero)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func performRotation(animated: Bool = true) {
        triangles.forEach {
            $0.isReversed.toggle()
            $0.changePosition(to: nextPosition(of: $0))
        }
        initialPosition = initialTriangle.position
        let angle = getNextAngle()
        guard animated else { return }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override public func copy() -> Any {
        return Figure(trianglesColor: color, forTriangleCount: triangleCount)
    }
    
    private func initialize() {
        makeTriangles()
    }
    
    private func getNextAngle() -> CGFloat {
        rotationIndex += 1
        if rotationIndex == rotation.count {
            rotationIndex = 0
        }
        return rotation[rotationIndex]
    }
    
    private func makeTriangles() {
        for index in 0..<triangleCount {
            let position: Position
            if index < 3 {
                position = Position(row: 0, column: index)
            } else {
                position = Position(row: 1, column: index - 3)
            }
            let triangleView = TriangleView(color: color, position: position)
            triangles.append(triangleView)
            addSubview(triangleView)
            makeConstraints(for: triangleView, at: index)
        }
    }
    
    private func makeConstraints(for triangle: TriangleView, at index: Int) {
        triangle.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstant = CGFloat(GameConstants.xPosition * (index % 3))
        let topConstant: CGFloat = CGFloat((index >= 3) ? GameConstants.yPosition : 0) + CGFloat(triangle.isReversed ? GameConstants.padding : 0)
        
        if index == 2 || index == triangleCount - 1 && triangleCount <= 3 {
            triangle.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        if index == 3 || triangleCount <= 3 {
            triangle.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        triangle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant).isActive = true
        triangle.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).isActive = true
        triangle.heightAnchor.constraint(equalToConstant: GameConstants.size).isActive = true
        triangle.widthAnchor.constraint(equalToConstant: GameConstants.size).isActive = true
    }
}

