import UIKit

public class Board: UIView {
    
    public var addPoint: ((Int) -> Void)?
    public var hexagons = [Hexagon]()
    public var triangles = [TriangleView]()
    
    private let maxTrianglesInRow = 11
    private let numberOfRows = 6
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public func highlight(_ figure: Figure) {
        for triangle in trianglesToPlace(from: figure) {
            triangle.highlight(withColor: figure.color.withAlphaComponent(0.5))
        }
    }
    
    public func unhighlight() {
        for triangle in triangles.filter ({ $0.shouldUnhighlight }) {
            triangle.unhighlight()
        }
    }
    
    public func tryPlace(_ figure: Figure) -> Bool {
        let placeableTriangles = trianglesToPlace(from: figure)
        for triangle in placeableTriangles {
            triangle.fill(withColor: figure.color)
        }
        clearBoard()
        return !placeableTriangles.isEmpty
    }
    
    var animationInProgress = false
    
    
    public func canPlace(_ figure: Figure) -> Bool {
        let possibleBoardPosition = getPossibleBoardPosition(forInitialTriangle: figure.initialTriangle)
        for position in possibleBoardPosition {
            if canPlace(figure: figure, on: position) {
                return true
            }
        }
        return false
    }
    
    private func initialize() {
        backgroundColor = .boardBackground
        initializeRows()
        createHexagons()
        makeBoardConstraints()
    }
    
    private func initializeRows() {
        createRow(0, offset: 2)
        createRow(1, offset: 1)
        createRow(2, offset: 0)
        createRow(3, offset: 0)
        createRow(4, offset: 1)
        createRow(5, offset: 2)
    }
    
    private func createRow(_ row: Int, offset: Int) {
        let trianglesInRow = maxTrianglesInRow - offset * 2
        for column in 0..<trianglesInRow {
            let position = Position(row: row, column: column + offset)
            initilizeTriangle(at: position)
        }
    }
    
    private func initilizeTriangle(at position: Position) {
        let triangle = TriangleView(position: position)
        addSubview(triangle)
        triangles.append(triangle)
        positionToTriangle[position] = triangle
        makeConstraints(forTriangle: triangle, position: position)
    }
    
    private func createHexagons() {
        for (position, triangle) in positionToTriangle {
            if triangle.isReversed {
                continue
            }
            let topRight = Position(row: position.row, column: position.column + 2)
            let bottomRight = Position(row: position.row + 1, column: position.column + 2)
            
            guard
                let _ = positionToTriangle[topRight],
                let _ = positionToTriangle[bottomRight]
                else { continue }
            
            hexagons.append(Hexagon(withInitialPosition: position))
        }
    }
    
    private func makeConstraints(forTriangle triangle: TriangleView, position: Position) {
        let padding: CGFloat = triangle.isReversed ? GameConstants.padding : 0
        let leadingConstant = CGFloat(GameConstants.xPosition * position.column)
        let topConstant = CGFloat(GameConstants.yPosition * position.row) + padding
        triangle.translatesAutoresizingMaskIntoConstraints = false
        triangle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant).isActive = true
        triangle.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).isActive = true
        triangle.heightAnchor.constraint(equalToConstant: GameConstants.size).isActive = true
        triangle.widthAnchor.constraint(equalToConstant: GameConstants.size).isActive = true
    }
    
    private func makeBoardConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: CGFloat(6 * GameConstants.yPosition)).isActive = true
        widthAnchor.constraint(equalToConstant: CGFloat(11 * GameConstants.xPosition) + 20).isActive = true
    }
    
    private func trianglesToPlace(from figure: Figure) -> [TriangleView] {
        guard let boardPosition = initialTrianglePosition(from: figure) else { return [] }
        
        var placeableTriangles = [TriangleView]()
        for triangle in figure.triangles {
            guard let boardTriangle = getPlaceableTriangle(from: triangle, boardPosition: boardPosition, figure: figure) else { return [] }
            
            placeableTriangles.append(boardTriangle)
        }
        return placeableTriangles
    }
    
    private func initialTrianglePosition(from figure: Figure) -> Position? {
        let initialTriangle = figure.initialTriangle
        let triangleCenter = convert(initialTriangle.center, from: figure)
        return boardTrianglePosition(from: initialTriangle, center: triangleCenter)
    }
    
    private func getPlaceableTriangle(from triangle: TriangleView, boardPosition: Position, figure: Figure) -> TriangleView? {
        let position = convertPosition(in: triangle, from: boardPosition, figure: figure)
        guard let boardTriangle = isTriangleExists(at: position),
            boardTriangle.canFill(isReversed: triangle.isReversed)
            else { return nil }
        
        return boardTriangle
    }
    
    private func boardTrianglePosition(from triangle: TriangleView, center: CGPoint) -> Position? {
        guard let boardTriangle = triangles.first(where: { $0.contains(point: center) && $0.isReversed == triangle.isReversed }) else { return nil }
        
        return boardTriangle.position
    }
    
    private func convertPosition(in triangle: TriangleView, from position: Position, figure: Figure) -> Position {
        return position.add(position: triangle.position).subtract(position: figure.initialPosition)
    }
    
    private func isTriangleExists(at position: Position) -> TriangleView? {
        return triangles.first(where: { $0.position == position })
    }
    
    private func getMatchingHexagons(for position: Position) -> [Hexagon] {
        return hexagons.filter { $0.contains(position: position) }
    }
    
    private func clearBoard() {
        let completedHexagon = hexagons.filter { $0.isCompleted }
        completedHexagon.forEach { removeCompleted($0) }
    }
    
    private func getPossibleBoardPosition(forInitialTriangle initialTriangle: TriangleView) -> [Position] {
        let boardTriangles = triangles.filter { $0.canFill(isReversed: initialTriangle.isReversed) }
        return boardTriangles.map { $0.position }
    }
    
    private func canPlace(figure: Figure, on boardPosition: Position) -> Bool {
        for triangle in figure.triangles {
            let position = convertPosition(in: triangle, from: boardPosition, figure: figure)
            if isTriangleExists(at: position)?.isFilled != false {
                return false
            }
        }
        return true
    }
    
    
    
    var toAnimate = [TriangleView]()
    
    private func removeCompleted(_ hexagon: Hexagon) {
        for position in hexagon.positions {
            toAnimate.append( positionToTriangle[position]!)
        }
        toAnimate.sort(by: {
            if $0.position.row == $1.position.row {
                return $0.position.column < $1.position.column
            }
            return $0.position.row < $1.position.row
        })
        animate()
        addPoint?(60)
    }
    
    @objc func animate() {
        if toAnimate == [] {
            animationInProgress = false
            return
        }
        animationInProgress = true
        let triangle = toAnimate.removeFirst()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
            triangle.alpha = 0.0
            Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.animate), userInfo: nil, repeats: false)
        }, completion: { _ in
            triangle.unfill()
            UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
                triangle.alpha = 1.0
            })
        })
        
        
    }
}
