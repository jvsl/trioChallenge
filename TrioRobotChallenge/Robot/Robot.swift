import Foundation

protocol RobotEngine {
    func start()
    func restart()
    
    var prizePosition: RobotPosition { get set }
    var rightRobotCurrentPosition: RobotPosition { get set }
    var leftRobotCurrentPosition: RobotPosition { get set }
    var leftRobotUpdatedPosition: ((RobotTrackPosition) -> Void)? { get set }
    var rightRobotUpdatedPosition: ((RobotTrackPosition) -> Void)? { get set }
    var updateLeftScore: ((Int) -> Void)? { get set }
    var updateRightScore: ((Int) -> Void)? { get set }
    var draw: ((Int) -> Void)? { get set }
    var restartGame: (() -> Void)? { get set }
}

final class Robot: RobotEngine {
    private var delayToMoveNextRobot: TimeInterval = 0.5
    private var delayToStart: TimeInterval = 1
    private var leftWins = 0
    private var rightWins = 0
    private var drawWins = 0
    private let prize = 0
    private var board = Matrix<PositionStatus>(
        rows: Constants.rows, columns: Constants.columns, defaultValue: .unoccupied)
    private var rightRobotFinish = false
    private var leftRobotFinish = false
    private var robotsDraw = false
    private var canRestartRobots: Bool {
        rightRobotFinish && leftRobotFinish
    }
    
    lazy var prizePosition = randomPrizePosition()
    var rightRobotCurrentPosition = RobotPosition(row: 0, column: Constants.columns - 1)
    var leftRobotCurrentPosition = RobotPosition()
    var leftRobotUpdatedPosition: ((RobotTrackPosition) -> Void)?
    var rightRobotUpdatedPosition: ((RobotTrackPosition) -> Void)?
    var updateLeftScore: ((Int) -> Void)?
    var updateRightScore: ((Int) -> Void)?
    var draw: ((Int) -> Void)?
    var restartGame: (() -> Void)?

    init() {
        board[prizePosition.row, prizePosition.column] = .prize
        board[leftRobotCurrentPosition.row, leftRobotCurrentPosition.column] = .occupied
        board[rightRobotCurrentPosition.row, rightRobotCurrentPosition.column] = .occupied
    }
  
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToStart) {
            self.moveLeftRobot()
        }
    }
    
    func restart() {
        if canRestartRobots {
            incrementDraw()
    
            prizePosition = randomPrizePosition()
            
            initialRobotsPosition()
            
            initialBoardPosition()
            
            updateRobotsState(leftRobot: false, rightRobot: false)
            
            restartGame?()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayToStart) {
                self.start()
            }
        }
    }
    
    private func updateRobotsState(leftRobot: Bool, rightRobot: Bool) {
        leftRobotFinish = leftRobot
        rightRobotFinish = rightRobot
    }
    
    private func validPosition(_ positions: [RobotPosition]) -> RobotPosition? {
        
        guard !positions.isEmpty, let position = positions.randomElement() else {
            return nil
        }
        
        return position
    }
    
    private func generateRandomPosition(_ robotPosition: RobotPosition) -> [RobotPosition] {
        let left = RobotPosition(
            row: robotPosition.row, column: robotPosition.column - 1)
        
        let right = RobotPosition(
            row: robotPosition.row, column: robotPosition.column + 1)
        
        let top = RobotPosition(
            row: robotPosition.row + 1, column: robotPosition.column)
        
        let down = RobotPosition(
            row: robotPosition.row - 1, column: robotPosition.column)
        
        let validPositions = [left, right, top, down].filter { isAvalidPosition(position: $0)}
        
        return validPositions
    }
    
    private func isOutOfBounds(position: RobotPosition) -> Bool {
        board.indexIsValid(row: position.row, column: position.column)
    }
    
    private func isPrize(position: RobotPosition) -> Bool {
        return board.indexIsValid(row: position.row, column: position.column) &&
        (board[position.row, position.column] == .prize)
    }
    
    private func isAvalidPosition(position: RobotPosition) -> Bool {
        
        return board.indexIsValid(row: position.row, column: position.column) &&
        (board[position.row, position.column] != .occupied)
    }
    
    private func randomPrizePosition() -> RobotPosition {
        let column = Int.random(in: 0...Constants.columns - 1)
        var row = Int.random(in: 0...Constants.rows - 1)
        
        // Avoiding to set the prize in the start robots position (0,0) or (0,6)
        if (column == 0 && row == 0) ||  (column == 6 && row == 0)  {
            row = row + 1
        }
        
        return RobotPosition(row: row, column: column)
    }
    
    private func initialBoardPosition() {
        board = Matrix<PositionStatus>(
            rows: Constants.rows,
            columns: Constants.columns,
            defaultValue: .unoccupied)
        board[prizePosition.row, prizePosition.column] = .prize
        board[leftRobotCurrentPosition.row, leftRobotCurrentPosition.column] = .occupied
        board[rightRobotCurrentPosition.row, rightRobotCurrentPosition.column] = .occupied
    }
    
    private func initialRobotsPosition() {
        rightRobotCurrentPosition = RobotPosition(row: 0, column: Constants.columns - 1)
        leftRobotCurrentPosition = RobotPosition()
    }
    
    private func incrementDraw() {
        if robotsDraw {
            drawWins += 1
            draw?(drawWins)
        }
    }

    private func updatePosition(currentPosition: RobotPosition, updatedPosition: RobotPosition) {
        currentPosition.column = updatedPosition.column
        currentPosition.row = updatedPosition.row
    }
}

// MARK: - Left Robot

extension Robot {
    @objc func moveLeftRobot() {
        let positionsAvaliable = generateRandomPosition(leftRobotCurrentPosition)
        
        let validPosition = validPosition(positionsAvaliable)
   
        if let position = validPosition {
            moveToUpToDateNextLeftPosition(position)
        } else {
            finishLeftRobot()
        }
        
        moveRightOrRestartIfNeeded()
    }
    
    private func moveToUpToDateNextLeftPosition(_ position: RobotPosition) {
        if board[position.row, position.column] == .prize {
            self.updateLeftRobotAfterWinAPrize(position: position)
        
            return
        } else {
            self.updateLeftRobotPosition(position: position)
        }
    }
    
    private func moveRightOrRestartIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToMoveNextRobot) {
            if self.canRestartRobots {
                self.restart()
            } else {
                self.moveRightRobot()
            }
        }
    }
    
    private func updateLeftRobotAfterWinAPrize(position: RobotPosition) {
        leftWins += 1
        robotsDraw = false
       
        updateLeftScore?(leftWins)
        
        updateRobotsState(leftRobot: true, rightRobot: true)
        
        leftRobotUpdatedPosition?(RobotTrackPosition(
            lastRow: position.row,
            lastColumn: position.column,
            currentRow: position.row,
            currentColumn: position.column))

        DispatchQueue.main.asyncAfter(deadline: .now() + delayToStart) {
            self.restart()
        }
    }
    
    private func updateLeftRobotPosition(position: RobotPosition) {
        
        leftRobotUpdatedPosition?(RobotTrackPosition(
            lastRow: leftRobotCurrentPosition.row,
            lastColumn: leftRobotCurrentPosition.column,
            currentRow: position.row,
            currentColumn: position.column)
                                      )
        board[position.row, position.column] = .occupied
        updatePosition(currentPosition: leftRobotCurrentPosition, updatedPosition: position)
    }
    
    private func finishLeftRobot() {
        leftRobotFinish = true
        robotsDraw = true
    }
}

// MARK: - Right Robot

extension Robot {
    @objc func moveRightRobot() {
        let positionsAvaliable = generateRandomPosition(rightRobotCurrentPosition)

        let validPosition = validPosition(positionsAvaliable)
   
        if let position = validPosition {
            moveToUpToDateNextRightPosition(position)
        } else {
            finishRightRobot()
        }
        
        moveLeftOrRestartIfNeeded()
    }
    
    private func moveToUpToDateNextRightPosition(_ position: RobotPosition) {
        if board[position.row, position.column] == .prize {
            self.updateRightRobotAfterWinAPrize(position: position)
            return
        } else {
            self.updateRightRobotPosition(position: position)
        }
    }
    
    private func moveLeftOrRestartIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToMoveNextRobot) {
            if self.canRestartRobots {
                self.restart()
            } else {
                self.moveLeftRobot()
            }
        }
    }
    
    private func updateRightRobotAfterWinAPrize(position: RobotPosition) {
        rightWins += 1
        robotsDraw = false
        
        updateRightScore?(rightWins)
        
        updateRobotsState(leftRobot: true, rightRobot: true)
        
        rightRobotUpdatedPosition?(
            RobotTrackPosition(
                lastRow: position.row,
                lastColumn: position.column,
                currentRow: position.row,
                currentColumn: position.column)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToStart) {
            self.restart()
        }
    }
    
    private func updateRightRobotPosition(position: RobotPosition) {
        board[position.row, position.column] = .occupied
        
        rightRobotUpdatedPosition?(
            RobotTrackPosition(
                lastRow: rightRobotCurrentPosition.row,
                lastColumn: rightRobotCurrentPosition.column,
                currentRow: position.row,
                currentColumn: position.column)
        )
        
        updatePosition(
            currentPosition: rightRobotCurrentPosition,
            updatedPosition: position)
    }
    
    private func finishRightRobot() {
        rightRobotFinish = true
        robotsDraw = true
    }
}
