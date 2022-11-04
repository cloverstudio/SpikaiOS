//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Combine

class HomeViewController: UIPageViewController {
    
    var homeTabBar: HomeTabBar!
    var viewModel: HomeViewModel!
    
    var subscriptions = Set<AnyCancellable>()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        viewModel.updatePush()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
//        homeTabBar.handleTap(homeTabBar.tabs[2])
        
        self.viewModel.repository
            .unreadRoomsPublisher
            .sink { value in
                let stringValue = value > 0 ? String(value) : ""
                self.title = stringValue
            }.store(in: &self.subscriptions)
       }
    
    func configurePageViewController() {
        homeTabBar = HomeTabBar(tabBarItems: viewModel.getHomeTabBarItems())
    
        homeTabBar.delegate = self
        
        view.addSubview(homeTabBar)
        homeTabBar.anchor(leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        homeTabBar.constrainHeight(HomeTabBar.tabBarHeight)
        if let vc = homeTabBar.getViewController(index: 0) {
            self.setViewControllers([vc], direction: .forward, animated: true)
        }
    }
    
    private func switchToController(index: Int) {
        if let vc = homeTabBar.getViewController(index: index) {
            if index < homeTabBar.currentViewControllerIndex {
                setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            } else {
                setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
}

extension HomeViewController: HomeTabBarViewDelegate {
    func tabSelected(_ tabBar: HomeTabBar, at index: Int) {
        self.switchToController(index: index)
    }
}
