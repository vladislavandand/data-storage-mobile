//
//  SearchViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 20.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {

    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        return searchController
    }()
    
    var nodes = [Node]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.barStyle = .black

        navigationItem.searchController = searchController
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nodes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as! NodeCell
        
        let node = nodes[indexPath.row]
        cell.nodeNameLabel?.text = node.name
        cell.nodeDetailLabel?.text = ""
        
        if let detail = node.highlight?.documentsToSearchName {
            cell.nodeDetailLabel.text = detail[0]
        }
        //cell.nodeDetailLabel?.text = "Автор: \(node.creator!)"
        
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
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let parentNode = nodes[indexPath.row]
        
        switch parentNode.type! {
            
        case .folder:
            
            var vc: ExplorerViewController
            
            if parentNode.share {
                vc = self.storyboard?.instantiateViewController(withIdentifier: "explorerIDshare") as! ExplorerViewController
            } else {
                vc = self.storyboard?.instantiateViewController(withIdentifier: "explorerIDown") as! ExplorerViewController
            }

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
    
    
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

    //MARK: - Networking
    
    func searchText(_ text: String) {
        
        DataStorageClient.shared.searchNode(searchText: text) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let nodes,let meta):
                    
                    
                    self.nodes = nodes
                    self.tableView.reloadData()
                    print("NODES HERE! \(self.nodes)")
                    
                    
                case .failure(let err):
                    self.nodes = [Node]()
                    self.tableView.reloadData()
                    
                }
                
            }
        }
        
    }
    
    func searchNodesForSearchText(_ searchText: String) {
        
        self.searchText(searchText)
    }
    
    //MARK: - Keyboard
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            setupInsetForScrollView(y: keyboardSize.height)
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        setupInsetForScrollView(y: 0)
//    }
    
    func setupInsetForScrollView(y: CGFloat) {
        let inset = UIEdgeInsetsMake(0, 0, y, 0)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset

        })
    }

}

extension SearchViewController: UISearchControllerDelegate {

//    func willPresentSearchController(_ searchController: UISearchController) {
//        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchController.searchBar.text!
        if searchText.count > 2 {
            self.searchText(searchController.searchBar.text!)
        } else {
            self.nodes = [Node]()
            self.tableView.reloadData()
        }
        
        
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        let searchText = searchController.searchBar.text!
//        if searchText.count > 2 {
//            searchNodesForSearchText(searchController.searchBar.text!)
//        }
//        self.tableView.reloadData()
    }
}
