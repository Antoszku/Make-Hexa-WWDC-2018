// TODO DO I NEED HASHABLE?

public struct Position: Hashable {
    
    public private(set) var row: Int
    public private(set) var column: Int
    
    public var hashValue: Int {
        return String("row\(row)column\(column)").hashValue
    }
    
    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
    public func add(position: Position) -> Position {
        return Position(row: self.row + position.row, column: self.column + position.column)
    }
    
    public func subtract(position: Position) -> Position {
        return Position(row: self.row - position.row, column: self.column - position.column)
    }
}

extension Position: Equatable {
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}
