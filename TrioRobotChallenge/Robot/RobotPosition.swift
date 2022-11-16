struct RobotTrackPosition {
    var lastRow: Int
    var lastColumn: Int
    var currentRow: Int
    var currentColumn: Int
}

enum PositionStatus: Int {
    case occupied = -1
    case unoccupied = 1
    case prize = 0
}

class RobotPosition {
    var row: Int = 0
    var column: Int = 0
    
    init(row: Int = 0, column: Int = 0) {
        self.row = row
        self.column = column
    }
}
