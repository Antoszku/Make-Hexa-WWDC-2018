import UIKit

public class Board: UIView {
    
    public var addPoints: ((Int) -> Void)?
    public var hexagons = [Hexagon]()
    public var triangles = [TriangleView]()
    public var animationInProgress: Bool {
        get {
            return !triangleToRemove.isEmpty
        }
    }
    
    private var triangleToRemove = [TriangleView]()
    private var positionToTriangle = [Position: TriangleView]()
    private let maxTrianglesInRow = 11
    private let numberOfRows = 6
    
    init() {
        super.init(frame: .zero)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func highlight(figure: Figure) {
        for triangle in trianglesToPlace(from: figure) {
            triangle.highlight(withColor: figure.color.withAlphaComponent(0.5))
        }
    }
    
    public func unhighlight() {
        for triangle in triangles.filter ({ $0.shouldUnhighlight }) {
            triangle.unhighlight()
        }
    }
    
    public func tryPlace(figure: Figure) -> Bool {
        let placeableTriangles = trianglesToPlace(from: figure)
        for triangle in placeableTriangles {
            triangle.fill(withColor: figure.color)
        }
        clearBoard()
        return !placeableTriangles.isEmpty
    }
    
    public func canPlace(figure: Figure) -> Bool {
        let possibleBoardPosition = getPossibleBoardPosition(forInitialTriangle: figure.initialTriangle)
        for position in possibleBoardPosition {
            if canPlace(figure: figure, on: position) {
                return true
            }
        }
        return false
    }
    
    public func clean() {
        triangles.forEach { $0.removeFromSuperview() }
        positionToTriangle = [Position: TriangleView]()
        triangles = []
        initializeRows()
    }
    
    private func initialize() {
        backgroundColor = .boardBackground
        initializeRows()
        createHexagons()
        makeConstraints()
    }
    
    private func initializeRows() {
        createRow(0, withOffset: 2)
        createRow(1, withOffset: 1)
        createRow(2, withOffset: 0)
        createRow(3, withOffset: 0)
        createRow(4, withOffset: 1)
        createRow(5, withOffset: 2)
    }
    
    private func createHexagons() {
        for (position, triangle) in positionToTriangle {
            guard !triangle.isReversed else { continue }
            
            let topRight = Position(row: position.row, column: position.column + 2)
            let bottomRight = Position(row: position.row + 1, column: position.column + 2)
            
            guard
                let _ = positionToTriangle[topRight],
                let _ = positionToTriangle[bottomRight]
                else { continue }
            
            hexagons.append(Hexagon(withInitialPosition: position))
        }
    }
    
    private func makeConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: CGFloat(6 * GameConstants.yPosition)).isActive = true
        widthAnchor.constraint(equalToConstant: CGFloat(11 * GameConstants.xPosition) + 20).isActive = true
    }
    
    private func createRow(_ row: Int, withOffset offset: Int) {
        let trianglesInRow = maxTrianglesInRow - offset * 2
        for column in 0..<trianglesInRow {
            initilizeTriangle(at: Position(row: row, column: column + offset))
        }
    }
    
    private func initilizeTriangle(at position: Position) {
        let triangle = TriangleView(position: position)
        addSubview(triangle)
        triangles.append(triangle)
        positionToTriangle[position] = triangle
        makeConstraints(forTriangle: triangle, position: position)
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
        return positionToTriangle[position]
    }
    
    private func getMatchingHexagons(for position: Position) -> [Hexagon] {
        return hexagons.filter { $0.contains(position: position) }
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
    
    private func clearBoard() {
        let completedHexagon = hexagons.filter { isHexagonCompleted($0) }
        completedHexagon.forEach { removeCompleted(hexagon: $0) }
    }
    
    private func isHexagonCompleted(_ hexagon: Hexagon) -> Bool {
        let color = positionToTriangle[hexagon.initialPosition]?.color
        for position in hexagon.positions {
            guard
                let triangle = positionToTriangle[position],
                triangle.isFilled,
                triangle.color == color else {
                    return false
            }
        }
        return true
    }
    
    private func removeCompleted(hexagon: Hexagon) {
        for position in hexagon.positions {
            triangleToRemove.append( positionToTriangle[position]!)
        }
        sortTriangleToRemove()
        removeTriangle()
        addPoints?(GameConstants.pointForHexagon)
    }
    
    @objc private func removeTriangle() {
        if triangleToRemove == [] {
            return
        }
        let triangle = triangleToRemove.removeFirst()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, animations: { [weak self] in
            guard let `self` = self else { return }
            
            triangle.alpha = 0.0
            Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.removeTriangle), userInfo: nil, repeats: false)
            }, completion: { _ in
                triangle.unfill()
                UIView.animate(withDuration: 0.05, delay: 0.0, animations: {
                    triangle.alpha = 1.0
                })
        })
    }
    
    private func sortTriangleToRemove() {
        triangleToRemove.sort(by: {
            if $0.position.row == $1.position.row {
                return $0.position.column < $1.position.column
            }
            return $0.position.row < $1.position.row
        })
    }
}
