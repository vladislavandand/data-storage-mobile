//
//  ExlorerViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 04.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

private let nodeCellIdentifier = "NodeCell"

class ExplorerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var copyBarButtonItem: UIBarButtonItem!
    private let refreshControl = UIRefreshControl()
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .minimal
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        return searchController
    }()
    
    var nodes = Nodes()
    var parentNode: Node? = nil
    
    var tab: Tab {
        return Tab(rawValue: self.tabBarController!.selectedIndex)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let copy = CopyManager.shared.copy {
            copyBarButtonItem.tintColor = UIColor.white
            if isCopyAvailable() {
                self.copyBarButtonItem.isEnabled = true
            }
            
        } else {
            self.copyBarButtonItem.isEnabled = false
            copyBarButtonItem.tintColor = UIColor.clear
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchNodes()
        setupView()
        
    }
    
    // MARK: - Helpers
    
    private func setupView() {
        
        setupTableView()
        setupMessageLabel()
        setupActivityIndicatorView()
        
    }
    
    
    private func setupTableView() {
        tableView.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refreshNodes(sender:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func setupMessageLabel() {
        
        messageLabel.isHidden = true
        
    }
    
    private func setupActivityIndicatorView() {
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
    }
    
    private func updateView() {
        let hasNodes = nodes.count > 0
        tableView.isHidden = !hasNodes
        messageLabel.isHidden = hasNodes
        
        if hasNodes {
            print("reload")
            tableView.reloadData()
        }
    }
    
    @objc func refreshNodes(sender: UIRefreshControl) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        fetchNodes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(self.nodes.count)")
        return self.nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: nodeCellIdentifier, for: indexPath) as! NodeCell
        
        let node = nodes[indexPath.row]
        cell.nodeNameLabel?.text = node.name
        cell.nodeDetailLabel?.text = "Автор: \(node.creator!)"
        cell.delegate = self
        cell.indexPath = indexPath
        
        if node.type == .folder {
            
            if node.share {
                cell.nodeTypeImageView?.image = #imageLiteral(resourceName: "folder_shared")
            } else {
                cell.nodeTypeImageView?.image = #imageLiteral(resourceName: "folder")
            }
            
        } else {
            cell.nodeTypeImageView?.image = #imageLiteral(resourceName: "file")
        }
        
        return cell
        
    }
    
    // MARK: - delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let parentNode = nodes[indexPath.row]
        
        switch parentNode.type! {
            
        case .folder:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: self.restorationIdentifier!) as! ExplorerViewController
            let node = nodes[indexPath.row]
            vc.parentNode = node
            vc.title = node.name
            self.navigationController?.pushViewController(vc, animated: true)
        
        case .document:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "infoID") as! InfoViewController
            vc.node = nodes[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Networking
    
    func fetchNodes() {
        if (self.parentNode != nil) {
            fetchChildNodes()
        } else {
            fetchNodesFromRoot()
        }
    }
    
    func fetchNodesFromRoot() {
        
        DataStorageClient.shared.getNodesForTab(tab: self.tab, completionHandler: { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let nodes,let meta):
                    
                    print("NODES HERE!")
                    self.nodes = nodes
                    
                    if self.nodes.count == 0 {
                        self.folderIsEmptySetup()
                        print("Папка пуста")
                    } else {
                        self.fetchSuccessSetup()
                    }
                    
                case .failure(let err):
                    self.internetFailureSetup(err: err)
                    
                    self.nodes = Nodes()
                    
                }
            }
        })
    }
    
    func fetchChildNodes() {
        
        DataStorageClient.shared.getChildNodes(id: (self.parentNode?.id)!, completionHandler: { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let nodes,let meta):
                    
                    print("NODES HERE!")
                    self.nodes = nodes
                    
                    if self.nodes.count == 0 {
                        self.folderIsEmptySetup()
                    } else {
                        self.fetchSuccessSetup()
                    }
                    
                
                case .failure(let err):
                    self.nodes = Nodes()
                    self.internetFailureSetup(err: err)
                }
            }
        })
    }
    
    private func folderIsEmptySetup() {
        self.messageLabel.text = "Директория пуста"
        self.refreshControl.endRefreshing()
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateView()
    }
    
    private func fetchSuccessSetup() {
        self.refreshControl.endRefreshing()
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateView()
    }
    
    private func internetFailureSetup(err: Error) {
        print("SORRY: \(err.localizedDescription)")
        self.messageLabel.text = "Упс... Что-то с интернетом..."
        self.refreshControl.endRefreshing()
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateView()
    }
    
    private func isCopyAvailable() -> Bool{
        if let parent = parentNode {
            return parent.role != .read
        } else {
            return self.restorationIdentifier == "explorerIDown"
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let node = nodes[indexPath.row]
            print("Delete")
            DataStorageClient.shared.deleteNode(id: node.id!, completionHandler: { (result) in
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    self.nodes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            })
        }
    }
    
    @IBAction func copyBarButtonAction(_ sender: UIBarButtonItem) {

        fetchNodes()
        setupView()
        
        DataStorageClient.shared.copyNode(CopyManager.shared.copy!, toNodeWithId: parentNode?.id) { (result) in
            self.fetchNodes()
            DispatchQueue.main.async {

                CopyManager.shared.copy = nil
                self.copyBarButtonItem.isEnabled = false
                self.copyBarButtonItem.tintColor = UIColor.clear
                
//                var node = CopyManager.shared.copy
//                node?.id = nil
//
//                self.tableView.beginUpdates()
//                self.nodes.insert(node!, at: 0)
//                let indexPath = IndexPath(row: 0, section: 0)
//                self.tableView.insertRows(at: [indexPath], with: .automatic)
//                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addNode") {
            let vc = segue.destination as! NodeCreationViewController
            vc.parentNodeId = parentNode?.id
        }
    }
    
    
}

extension ExplorerViewController: NodeCellDelegate {
    func moreActionAtIndexPath(_ indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Переименовать", style: .default, handler: { (action) in
            self.renameNodeAtIndexPath(indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Настройка доступа", style: .default, handler: { (action) in
            self.showShareSettingAtIndexPath(indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Инфо", style: .default, handler: { (action) in
            self.showInfoAtIndexPath(indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Копировать", style: .default, handler: { (action) in
            self.copyNodeAtIndexPath(indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (action) in
            self.deleteNodeAtIndexPath(indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func renameNodeAtIndexPath(_ indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "nodeRenameID") as! NodeRenameController
        vc.node = self.nodes[indexPath.row]
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showShareSettingAtIndexPath(_ indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShareSettingsID") as! ShareSettingsController
        vc.node = self.nodes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showInfoAtIndexPath(_ indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "infoID") as! InfoViewController
        vc.node = self.nodes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func copyNodeAtIndexPath(_ indexPath: IndexPath) {
        
        CopyManager.shared.copy = self.nodes[indexPath.row]
        copyBarButtonItem.tintColor = UIColor.white
        if isCopyAvailable() {
            self.copyBarButtonItem.isEnabled = true
        } else {
            self.copyBarButtonItem.isEnabled = false
        }
        
        

    }
    
    func deleteNodeAtIndexPath(_ indexPath: IndexPath) {
        let node = self.nodes[indexPath.row]
        DataStorageClient.shared.deleteNode(id: node.id!, completionHandler: { (result) in
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.nodes.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        })
    }
    
}

