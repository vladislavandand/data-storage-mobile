//
//  ShareSettingsController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 24.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

private let sectionTitles = ["", "Пользователи", "Группы пользователей", ""]
private let nodeCellIdentifier = "NodeCell"
private let roleCellIdentifier = "RoleCell"
private let addRoleCellIdentifier = "addRoleCell"
private let defaultCellIdentifier = "defaultCell"

class ShareSettingsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var node: Node? = nil
    
    var userRoles = [NodeUserRole]()
    var mailingListRoles = [NodeMailingListRole]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareData()
        setupView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        //let hasUsers = userRoles.count > 0
        tableView.isHidden = false
        messageLabel.isHidden = true
        print("userRoles.count = \(userRoles.count), mailingList.count = \(mailingListRoles.count)")
        //if hasUsers {
            print("reload")
            tableView.reloadData()
        //}
    }
    
    func prepareData() {
        let client = DataStorageClient.shared
        let id = (node?.id)!

        client.getUserRoles(id: id, completionHandler: { (usersResult) in
            client.getMailingListRoles(id: id, completionHandler: { (mailingListsResult) in
                DispatchQueue.main.async {
                    switch (usersResult, mailingListsResult) {
                    case (.success(let users, _),
                          .success(let mailingLists, _)):
                        
                        print("ROLES HERE!")
 
                        self.userRoles = users
                        self.mailingListRoles = mailingLists
                        self.fetchSuccessSetup()
                        
                    case (.failure(let err), .success(_, _)):
                        self.internetFailureSetup(err: err)
                    case (.success(_, _), .failure(let err)):
                        self.internetFailureSetup(err: err)
                    case (.failure(let err), .failure(_)):
                        self.internetFailureSetup(err: err)
                        
                    }
                }
            })
        })
    }
    
    private func fetchSuccessSetup() {
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateView()
    }
    
    private func internetFailureSetup(err: Error) {
        print("SORRY: \(err.localizedDescription)")
        self.messageLabel.text = "Упс... Что-то с интернетом..."
        self.activityIndicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.userRoles = [NodeUserRole]()
        self.mailingListRoles = [NodeMailingListRole]()
        
        self.updateView()
        
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addRole") {
            let vc = segue.destination as! UsersViewController
            vc.node = node
            vc.userRoles = userRoles
            vc.mailingListRoles = mailingListRoles
        }
    }

}

extension ShareSettingsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return userRoles.count
        case 2:
            return mailingListRoles.count
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let section = indexPath.section
        let row = indexPath.row
        
        guard let node = node else {
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath)
            return cell
        }
        
        switch section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nodeCellIdentifier, for: indexPath) as! NodeCell
            
            cell.nodeNameLabel?.text = node.name
            cell.nodeDetailLabel?.text = "Автор: \(node.creator!)"
            
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
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: roleCellIdentifier, for: indexPath) as! RoleCell
            let userRole = userRoles[row]
            cell.userLabel.text = userRole.user.name
            cell.roleLabel.text = userRole.role.localized()
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: roleCellIdentifier, for: indexPath) as! RoleCell
            let mailingListRole = mailingListRoles[row]
            cell.userLabel.text = mailingListRole.mailingList.name
            cell.roleLabel.text = mailingListRole.role.localized()
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: addRoleCellIdentifier, for: indexPath) as! AddRoleCell
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}


extension ShareSettingsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "editUserRoleID") as! UserRoleEditingController
            vc.node = self.node
            vc.indexPath = indexPath
            vc.userRole = userRoles[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 2 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "editMailingListRoleID") as! MailingListRoleEditingController
            vc.node = self.node
            vc.indexPath = indexPath
            vc.mailingListRole = mailingListRoles[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}

