//  StatisticController.swift

import UIKit

final class StatisticController: UIViewController {
    
    private lazy var mainImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noAnalizeData")
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var mainTitleLabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.textAlignment = .center
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let tableViewController = TableStatisticController()
    let viewModel: StatisticViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainViewBack
        setNavigationBar()
        setupTableViewController()
        setupViewsConstraint()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.cleanData()
    }
    
    init(viewModel: StatisticViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.bestScore = { [weak self] perfectDay in
            self?.tableViewController.dataScore[0] = perfectDay
        }
        
        viewModel.actualRecord = { [weak self] record in
            self?.tableViewController.dataScore[1] = record
        }
        
        viewModel.finishTrackers = {[weak self] trackDidFinish in
            self?.tableViewController.dataScore[2] = trackDidFinish
        }
        viewModel.midValueRecord = { [weak self] trackPerDay in
            self?.tableViewController.dataScore[3] = trackPerDay
        }
        viewModel.closeTable = { [weak self] status in
            self?.tableViewController.view.isHidden = status
            self?.mainImageView.isHidden = !status
            self?.mainTitleLabel.isHidden = !status
        }
    }
    
    private func checkUpdate() {
        viewModel.checkUpdate()
    }
    
    private func setupTableViewController() {
        addChild(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMove(toParent: self)
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViewsConstraint(){
        guard let tableView = tableViewController.view else { return }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 117),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            mainImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            mainTitleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8),
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setNavigationBar(){
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        
        navigationBar.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor , constant: 16),
            label.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            label.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 44),
        ])
    }
}
