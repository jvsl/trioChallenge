import UIKit

final class BoardViewController: UIViewController {
    
    private var viewModel: BoardViewModeling = BoardViewModel()
    private lazy var boardView = BoardView(viewModel: viewModel)
    private lazy var robotViewModel: RobotViewModeling = RobotViewModel(
        boardViewModel: viewModel, robotEngine: Robot())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildView()
        
        robotViewModel.start()
    }
}

extension BoardViewController: ViewCoding {
    func addSubviews() {
        view.addSubview(boardView)
    }
    
    func addConstraints() {
        boardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.boardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.boardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func additionalConfig() {
        view.backgroundColor = .white
    }
}

