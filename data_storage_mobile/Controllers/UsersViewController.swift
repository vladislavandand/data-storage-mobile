//
//  UsersViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 14.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit
import Kingfisher

enum Scope: Int {
    case users
    case mailingLists
}


class UsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        //searchController.searchBar.searchBarStyle = .minimal
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        return searchController
    }()

    var currentScope: Scope {
        return Scope(rawValue: searchController.searchBar.selectedScopeButtonIndex)!
    }
    
    var node: Node? = nil
    var userRoles = [NodeUserRole]()
    var mailingListRoles = [NodeMailingListRole]()
    
    var users = [User]()
    var mailingLists = [MailingList]()
    
    var filteredUsers = [User]()
    var filteredMailingLists = [MailingList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.scopeButtonTitles = ["Пользователи", "Группы рассылок"]
        
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barStyle = .black
        //searchController.searchBar.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        prepareData()
        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    
    private func setupView() {
        
        tableView.isHidden = true
        messageLabel.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
    }

    
    private func updateView() {
        let hasUsers = users.count > 0
        tableView.isHidden = !hasUsers
        messageLabel.isHidden = hasUsers
        
        if hasUsers {
            print("reload")
            tableView.reloadData()
        }
    }

    
    func prepareData() {
        let client = DataStorageClient.shared
        client.getUsers { (usersResult) in
            client.getMailingLists( completionHandler: { (mailingListsResult) in
                
                switch (usersResult, mailingListsResult) {
                case (.success(let users, _),
                      .success(let mailingLists, _)):
                    
                    print("USERS and Mailing Lists HERE!")
                    self.users = users.filter({ (user) -> Bool in
                        let isEmpty = user.name.isEmpty
                        let isExisting = self.userRoles.contains(where: {$0.user.id == user.id})
                        return !isExisting && !isEmpty
                        
                    })
                    self.users = self.users.sorted(by: { $0.name < $1.name })
                    
                    self.mailingLists = mailingLists.filter({ (mailingList) -> Bool in
                        let isEmpty = mailingList.name.isEmpty
                        let isExisting = self.mailingListRoles.contains(where: {$0.mailingList.id == mailingList.id})
                        return !isExisting && !isEmpty
                        
                    })
                    
                    DispatchQueue.main.async {
                        self.fetchSuccessSetup()
                    }
                case (.failure(let err), .success(_, _)):
                    DispatchQueue.main.async {
                        self.internetFailureSetup(err: err)
                    }
                case (.success(_, _), .failure(let err)):
                    DispatchQueue.main.async {
                        self.internetFailureSetup(err: err)
                    }
                case (.failure(let err), .failure(_)):
                    DispatchQueue.main.async {
                        self.internetFailureSetup(err: err)
                    }

                
                }
                
            })
        }
            
        
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
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateView()
        
        self.users = [User]()
        self.filteredUsers = [User]()
        
        self.mailingLists = [MailingList]()
        self.filteredMailingLists = [MailingList]()
    }
    
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        
        if currentScope == .users {
            
            filteredUsers = users.filter({( user : User) -> Bool in
                if searchBarIsEmpty() {
                    return true
                } else {
                    return user.name.lowercased().contains(searchText.lowercased())
                }
            })
            tableView.reloadData()
            
        } else {
            
            filteredMailingLists = mailingLists.filter({( mailingList : MailingList) -> Bool in
                if searchBarIsEmpty() {
                    return true
                } else {
                    return mailingList.name.lowercased().contains(searchText.lowercased())
                }
            })
            tableView.reloadData()
            
        }
        
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setupInsetForScrollView(y: keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        setupInsetForScrollView(y: 0)
    }
    
    func setupInsetForScrollView(y: CGFloat) {
        let inset = UIEdgeInsetsMake(0, 0, y, 0)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset
            
        })
    }
    
    func addRoleAction(role: NodeUserRole, scope: Scope, item: Any)  {
        
        if scope == .users {
            let mailingList = item as! MailingList
        } else {
            let user = item as! NodeUser
        }
        
    }
    
}
extension UsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentScope == .users {
            if searchBarIsEmpty() {
                return users.count
            } else {
                return filteredUsers.count
            }
        } else {
            if searchBarIsEmpty() {
                return mailingLists.count
            } else {
                return filteredMailingLists.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if currentScope == .users {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            let user: User
            if searchBarIsEmpty() {
                user = users[indexPath.row]
            } else {
                user = filteredUsers[indexPath.row]
            }
            cell.nameLabel?.text = user.name
            let image = #imageLiteral(resourceName: "defaultAvatar")
            cell.avatarImageView?.kf.setImage(with: user.avatarURL, placeholder: image)

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mailingListCell", for: indexPath)
            
            let mailingList: MailingList
            if searchBarIsEmpty() {
                mailingList = mailingLists[indexPath.row]
            } else {
                mailingList = filteredMailingLists[indexPath.row]
            }
            cell.textLabel?.text = mailingList.name
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
}
extension UsersViewController: UISearchControllerDelegate {

//    func willPresentSearchController(_ searchController: UISearchController) {
//        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//    }
}

extension UsersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentScope == .users {
            let selectedUser = users[indexPath.row]
        } else {
            let selectedMailingList = mailingLists[indexPath.row]
            
        }
        
        let actionSheet = UIAlertController(title: "Укажите роль", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Чтение", style: .default, handler: { (action) in
            self.addRole(Role.read, indexPath: indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Запись", style: .default, handler: { (action) in
            self.addRole(Role.write, indexPath: indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Редактирование", style: .default, handler: { (action) in
            self.addRole(Role.manage, indexPath: indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func addRole(_ role: Role, indexPath: IndexPath) {
        
        if self.currentScope == .users {
            var selectedUser: User
            if self.searchBarIsEmpty() {
                selectedUser = self.users[indexPath.row]
            } else {
                selectedUser = self.filteredUsers[indexPath.row]
            }
            let nodeUser = NodeUser(id: selectedUser.id, name: selectedUser.name)
            let userRole = NodeUserRole(id: nil, role: role, mayDestroy: true, user: nodeUser)
            //self.userRoles.append(userRole)
            updateUserRoles(userRole: userRole)
        } else {
            var selectedMailingList: MailingList
            if self.searchBarIsEmpty() {
                selectedMailingList = self.mailingLists[indexPath.row]
            } else {
                selectedMailingList = self.filteredMailingLists[indexPath.row]
            }
            
            let mailingListRole = NodeMailingListRole(id: nil, role: role, mailingList: selectedMailingList)
            //self.mailingListRoles.append(mailingListRole)
            updateMailingLists(mailingListRole: mailingListRole)
        }
        
        
    }
    
    func updateUserRoles(userRole: NodeUserRole) {
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ShareSettingsController
        
        DataStorageClient.shared.editNode(node!, add: userRole) { (result) in
            switch result {
            case .success(let node,let meta):
                
                print("ROLES CHANGED")
                
                DispatchQueue.main.async {
                    
                    vc.userRoles = node.nodeUserRoles!
                    vc.mailingListRoles = node.nodeMailingListRoles!
                    //                        vc.tableView.beginUpdates()
                    //                        vc.nodes.insert(node, at: 0)
                    //                        let indexPath = IndexPath(row: 0, section: 0)
                    //                        vc.tableView.insertRows(at: [indexPath], with: .automatic)
                    //                        vc.tableView.endUpdates()
                    vc.tableView.reloadData()
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let err):
                print("ROLES NOT CHANGED")
                print(err)
            }
        }
        
    }
    
    func updateMailingLists(mailingListRole: NodeMailingListRole) {
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ShareSettingsController
        
        DataStorageClient.shared.editNode(node!, add: mailingListRole) { (result) in
            switch result {
            case .success(let node,let meta):
                
                print("ROLES CHANGED")
                
                DispatchQueue.main.async {
                    vc.userRoles = node.nodeUserRoles!
                    vc.mailingListRoles = node.nodeMailingListRoles!
                    //                        vc.tableView.beginUpdates()
                    //                        vc.nodes.insert(node, at: 0)
                    //                        let indexPath = IndexPath(row: 0, section: 0)
                    //                        vc.tableView.insertRows(at: [indexPath], with: .automatic)
                    //                        vc.tableView.endUpdates()
                    vc.tableView.reloadData()
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let err):
                print("ROLES NOT CHANGED")
                print(err)
            }
        }
        
    }
    
}

extension UsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
