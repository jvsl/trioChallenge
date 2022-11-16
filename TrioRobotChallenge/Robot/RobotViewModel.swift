protocol RobotViewModeling {
    func start()
}

final class RobotViewModel: RobotViewModeling  {
    private var boardViewModel: BoardViewModeling
    private var robot: RobotEngine
    
    init(boardViewModel: BoardViewModeling, robotEngine: RobotEngine) {
        self.boardViewModel = boardViewModel
        self.robot = robotEngine
    }
    
    private func bind() {
        robot.leftRobotUpdatedPosition = { [weak self] position in
            self?.boardViewModel.updateBoard?(
                position, Constants.leftRobotColorPath, Constants.leftRobotColor)
        }
        
        robot.rightRobotUpdatedPosition = { [weak self] position in
            self?.boardViewModel.updateBoard?(
                position, Constants.rightRobotColorPath, Constants.rightRobotColor)
        }
        
        robot.updateLeftScore = { [weak self] score in
            self?.boardViewModel.updateLeftScore?(score)
        }
        
        robot.updateRightScore = { [weak self] score in
            self?.boardViewModel.updateRightBoard?(score)
        }
        
        robot.draw = { [weak self] score in
            self?.boardViewModel.draw?(score)
        }
        
        self.robot.restartGame = { [weak self] in
            self?.restartBoard()
        }
    }
    
    private func restartBoard() {
        boardViewModel.resetColorBoard()
        
        startBoard()
    }
    
    private func startBoard() {
        boardViewModel.colors[robot.prizePosition.row,
                              robot.prizePosition.column] = Constants.prizeColor
        boardViewModel.colors[robot.rightRobotCurrentPosition.row,
                              robot.rightRobotCurrentPosition.column] = Constants.rightRobotColor
        boardViewModel.colors[robot.leftRobotCurrentPosition.row,
                              robot.leftRobotCurrentPosition.column] = Constants.leftRobotColor
        
        boardViewModel.updateView?()
    }
    
    func start() {
        startBoard()
        bind()
        robot.start()
    }
}
