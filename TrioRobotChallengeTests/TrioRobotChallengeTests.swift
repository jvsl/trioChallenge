import XCTest
@testable import TrioRobotChallenge

final class TrioRobotChallengeTests: XCTestCase {

    func testStartEngine_shouldUpdateViewAndColorsCorrectly() throws {
        let boardSpy = BoardViewModelSpy()
        let robot = Robot()
        let robotViewModel = RobotViewModel(
            boardViewModel: boardSpy, robotEngine: robot)
        robotViewModel.start()
        
        XCTAssertEqual(boardSpy.didCallUpdateView, 1)
        XCTAssertEqual(boardSpy.colors[robot.prizePosition.row, robot.prizePosition.column], .yellow)
        XCTAssertEqual(boardSpy.colors[robot.rightRobotCurrentPosition.row,
                                   robot.rightRobotCurrentPosition.column], .cyan)
        XCTAssertEqual(boardSpy.colors[robot.leftRobotCurrentPosition.row,
                                   robot.leftRobotCurrentPosition.column], .purple)
        
    }
}

final class BoardViewModelSpy: BoardViewModeling {
    var didCallUpdateBoard = 0
    var didCallUpdateLeftScore = 0
    var didCallUpdateRightScore = 0
    var didCallDraw = 0
    var didCallUpdateView = 0
    var didCallColers = 0
    
    lazy var updateBoard: ((TrioRobotChallenge.RobotTrackPosition, UIColor, UIColor) -> Void)? = { _, _, _ in
        self.didCallUpdateBoard += 1
    }
    
    lazy var updateLeftScore: ((Int) -> Void)? = { _ in
        self.didCallUpdateLeftScore += 1
    }
    
    lazy var updateRightBoard: ((Int) -> Void)? = { _ in
        self.didCallUpdateRightScore += 1
    }
    
    lazy var draw: ((Int) -> Void)? = { _ in
        self.didCallDraw += 1
    }
    
    lazy var updateView: (() -> Void)? = {
        self.didCallUpdateView += 1
    }
    
    var colors: TrioRobotChallenge.Matrix<UIColor> = Matrix<UIColor>(rows: 7, columns: 7, defaultValue: .white)
    
    func resetColorBoard() {
        didCallColers += 1
    }
}
