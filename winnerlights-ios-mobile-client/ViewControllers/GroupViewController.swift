//
//  GroupViewController.swift
//  winnerlights-ios-mobile-client
//
//  Created by yutatanamoto on 2020/11/26.
//

import UIKit
import nRFMeshProvision

class GroupViewController: UIViewController {
    
    var groups: [Group] = []
    
    fileprivate lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Add Group", style: .plain, target: self, action: #selector(addGroup))
        return button
    }()
    
    fileprivate lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        return button
    }()

    fileprivate lazy var groupTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = refreshButton
        groups = MeshNetworkManager.instance.meshNetwork?.groups ?? []
        view.addSubview(groupTableView)
        groupTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTableView.reloadData()
    }
    
    @objc func addGroup() {
        let vc = AddGroupViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        groupTableView.reloadData()
    }
    
    @objc func refresh() {
        groupTableView.reloadData()
    }
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
          ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let group = groups[indexPath.row]
        cell.textLabel?.text = "\(group.name): \(group.address)"
        return cell
    }
    
    
}

extension GroupViewController: GroupDelegate {
    
    func groupChanged(_ group: Group) {
//        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
//        groupTableView.insertRows(at: [IndexPath(row: meshNetwork.groups.count - 1, section: 0)], with: .automatic)
//        hideEmptyView()
        groups.append(group)
        groupTableView.reloadData()
    }
    
}

