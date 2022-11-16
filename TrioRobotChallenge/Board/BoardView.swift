import UIKit

private extension BoardView.Layout {
    static let boardScoreHeight: CGFloat = 50
    static let boardScoreSpacing: CGFloat = 50
    static let boardPaddingTop: CGFloat = 120
    static let boardFontSize: CGFloat = 50
}

final class BoardView: UIView {
    private let boardToScreenRatio = 0.9
    private var originX: CGFloat = 13
    private var originY: CGFloat = 35
    private var squareSide: CGFloat = 50
    private let circleRatio: CGFloat = 0.5
    private let circleRadius: CGFloat = 0.4
    private lazy var leftScore = makeLabel(color: Constants.leftRobotColor)
    private lazy var rightScore = makeLabel(color: Constants.rightRobotColor)
    private lazy var drawScore = makeLabel(color: Constants.prizeColor)
    private var scoreContainer = UIStackView()
    private var viewModel: BoardViewModeling
    fileprivate enum Layout {}

    init(viewModel: BoardViewModeling) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        backgroundColor = .black
       
        makeScoreBoard()
       
        self.viewModel.updateLeftScore = { [weak self] score in
            self?.leftScore.text = String(score)
        }
        
        self.viewModel.updateRightBoard = { [weak self] score in
            self?.rightScore.text = String(score)
        }
        
        self.viewModel.draw = { [weak self] score in
            self?.drawScore.text = String(score)
        }
        
        self.viewModel.updateView = { [weak self] in
            self?.setNeedsLayout()
        }
        
        self.viewModel.updateBoard = { [weak self] position, alphaColor, color in
            guard let self = self else { return }
            
            self.viewModel.colors[position.lastRow, position.lastColumn] = alphaColor
            self.viewModel.colors[position.currentRow, position.currentColumn] = color
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setupInitialBoardPosition()
        drawBoard()
    }
    
    private func setupInitialBoardPosition() {
        let boardWidth = bounds.width * boardToScreenRatio
        squareSide = boardWidth / CGFloat(Constants.columns)
        originX = (1 - boardToScreenRatio) * bounds.width / 2
        originY = (bounds.height - CGFloat(Constants.columns) * squareSide) / 2
    }
    
    private func drawBoard() {
        UIColor.gray.setFill()
        let boardPath = UIBezierPath(
            roundedRect: CGRect(
                x: originX,
                y: originY,
                width: CGFloat(Constants.columns) * squareSide,
                height: CGFloat(Constants.rows) * squareSide),
            cornerRadius: 0.25 * squareSide)
        boardPath.stroke()
        boardPath.fill()
        
        
        UIColor.white.setFill()
        for row in 0..<Constants.rows {
            for col in 0..<Constants.columns {
                drawCircle(row: row, col: col, color: viewModel.colors[row,col])
                
            }
        }
    }
    
    private func drawCircle(row: Int, col: Int, color: UIColor) {
        color.setFill()
        
        let circleCenterX: CGFloat = originX + circleRatio * squareSide + CGFloat(col) * squareSide
        let circleCenterY: CGFloat = originY + circleRatio * squareSide + CGFloat(row) * squareSide
        
        UIBezierPath(
            arcCenter: CGPoint(
                x: circleCenterX,
                y: circleCenterY),
                radius: circleRadius * squareSide,
                startAngle: 0,
                endAngle: 2 * CGFloat.pi,
            clockwise: true).fill()
    }
    
    private func makeLabel(color: UIColor) -> UILabel {
        let scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "0"
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = color
        scoreLabel.font = .systemFont(ofSize: Layout.boardFontSize, weight: .bold)
        
        return scoreLabel
    }
    
    private func makeScoreBoard() {
        scoreContainer.translatesAutoresizingMaskIntoConstraints = false
        scoreContainer.alignment = .center
        scoreContainer.spacing = Layout.boardScoreSpacing
        
        addSubview(scoreContainer)
        scoreContainer.addArrangedSubview(leftScore)
        scoreContainer.addArrangedSubview(rightScore)
        scoreContainer.addArrangedSubview(drawScore)
        
        NSLayoutConstraint.activate([
            self.scoreContainer.topAnchor.constraint(equalTo: topAnchor, constant: Layout.boardPaddingTop),
            self.scoreContainer.heightAnchor.constraint(equalToConstant: Layout.boardScoreHeight),
            self.scoreContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
