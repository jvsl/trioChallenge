import UIKit

protocol BoardViewModeling {
    var updateBoard: ((RobotTrackPosition, UIColor, UIColor) -> Void)? { get set }
    var updateLeftScore: ((Int) -> Void)? { get set }
    var updateRightBoard: ((Int) -> Void)? { get set }
    var draw: ((Int) -> Void)? { get set }
    var updateView: (() -> Void)? { get set }
    var colors: Matrix<UIColor> { get set }
    
    func resetColorBoard()
}

final class BoardViewModel: BoardViewModeling {
    lazy var colors = board()
    
    var updateBoard: ((RobotTrackPosition, UIColor, UIColor) -> Void)?
    var updateLeftScore: ((Int) -> Void)?
    var updateRightBoard: ((Int) -> Void)?
    var draw: ((Int) -> Void)?
    var updateView: (() -> Void)?
    
    func resetColorBoard() {
        colors = board()
    }
    
    private func board() -> Matrix<UIColor> {
        return Matrix<UIColor>(rows: Constants.rows, columns: Constants.columns, defaultValue: .white)
    }
}
