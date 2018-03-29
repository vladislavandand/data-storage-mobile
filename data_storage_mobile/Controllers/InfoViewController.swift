//
//  InfoViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 04.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

private let attributeCellIdentifier = "attributeCell"
private let roleCellIdentifier = "RoleCell"
private let creatorCellIdentifier = "creatorCell"
private let createTimeCellIdentifier = "createTimeCell"
private let documentCellIdentifier = "documentCell"
private let addAttributeCellIdentifier = "addAttributeCell"
private let addRoleCellIdentifier = "addRoleCell"
private let defaultCellIdentifier = "defaultCell"

class InfoViewController: UITableViewController {
    
    var node: Node? = nil
    
    private let sectionTitles = ["Общая информация", "Файлы", "Роли"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let node = node {
            self.title = node.name
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let userRoles = node?.nodeUserRoles {
            return 3
        } else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return (node?.documents!.count)!
        case 2:
            return (node?.nodeUserRoles!.count)!
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: creatorCellIdentifier, for: indexPath)
                cell.detailTextLabel?.text = node?.creator
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: createTimeCellIdentifier, for: indexPath)
                cell.detailTextLabel?.text = node?.createdAt
                return cell
            }
            
//        case 1:
//
//            if (node?.attributes!.keys.count)! != row {
//
//                let cell = tableView.dequeueReusableCell(withIdentifier: attributeCellIdentifier, for: indexPath) as! AttributeCell
//
//                let key = Array((node?.attributes?.keys)!)[row]
//                let value = node?.attributes?[key]
//                cell.keyTextFieled.text = key
//                cell.valueTextField.text = value
//
//                return cell
//
//            } else {
//
//                let addAttributeCell = tableView.dequeueReusableCell(withIdentifier: addAttributeCellIdentifier, for: indexPath) as! AddAttributeCell
//
//                return addAttributeCell
//
//            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: documentCellIdentifier, for: indexPath) as! DocumentCell
            let doc = node?.documents![row]
            cell.documentNameLabel?.text = doc?.name
            cell.documentImageView?.image = doc?.type.image()
            return cell
        case 2:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: roleCellIdentifier, for: indexPath) as! RoleCell
            let userRole = node?.nodeUserRoles![row]
            cell.userLabel.text = userRole?.user.name
            cell.roleLabel.text = userRole?.role.localized()
//                cell.userLabel.text = node?.nodeUserRoles![row].user.name
//                let roleIndex = node?.nodeUserRoles![row].role.segmentedControlValue()
//                cell.roleSegmentedControl.selectedSegmentIndex = roleIndex!
//
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath)
            return cell
        }

        
    }
    
    fileprivate func showDocumentBrowser(for url: URL) {
        let documentBrowser = UIDocumentInteractionController(url: url)
        documentBrowser.delegate = self
        documentBrowser.presentPreview(animated: true)
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        if indexPath.section == 1 {
            
            let document = node?.documents![row]
            
            DataStorageClient.shared.loadFile(document: document!, completion: { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let file, _):
                        let previewManager = PreviewManager.shared
                        previewManager.file = file
                        let vc = previewManager.previewViewControllerForFile(file, fromNavigation: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let err):
                        print("sorry")
                        
                    }
                }
                
                
                
            })
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let section = indexPath.section
//        let row = indexPath.row
//
        return 60
    
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "addUser") {
//            let vc = segue.destination as! UsersViewController
//            vc.userRoles = node?.nodeUserRoles
//        }
//    }

}

extension InfoViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.presentedViewController!
    }
}

