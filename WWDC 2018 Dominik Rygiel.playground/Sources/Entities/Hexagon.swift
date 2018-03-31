public struct Hexagon {
    
    public let initialPosition: Position
    public let positions: [Position]
    
    var isCompleted: Bool {
        get {
            return isHexagonCompleted()
        }
    }
    
    public init(withInitialPosition position: Position) {
        self.initialPosition = position
        self.positions = [
            Position(row: position.row, column: position.column),
            Position(row: position.row, column: position.column + 1),
            Position(row: position.row, column: position.column + 2),
            Position(row: position.row + 1, column: position.column),
            Position(row: position.row + 1, column: position.column + 1),
            Position(row: position.row + 1, column: position.column + 2),
        ]
    }
    
    public func contains(position: Position) -> Bool {
        return positions.contains(position)
    }
    
    private func isHexagonCompleted() -> Bool {
        let color = positionToTriangle[initialPosition]?.color
        for position in positions {
            guard
                let triangle = positionToTriangle[position],
                triangle.isFilled,
                triangle.color == color else {
                    return false
            }
        }
        return true
    }
}
