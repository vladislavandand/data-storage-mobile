//
//  RoleEditingController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 24.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class UserRoleEditingController: UITableViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    var node: Node?
    var userRole: NodeUserRole?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userLabel.text = userRole?.user.name
        self.roleSegmentedControl.selectedSegmentIndex = (userRole?.role.segmentedControlValue())!

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ShareSettingsController
        
        DataStorageClient.shared.node(node!, destroyUserRole: userRole!) { (result) in
            DispatchQueue.main.async {
//                vc.tableView.beginUpdates()
//                vc.userRoles.remove(at: (self.indexPath?.row)!)
//                vc.tableView.deleteRows(at: [self.indexPath!], with: .automatic)
//                vc.tableView.endUpdates()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func confirmButtonAction(_ sender: RoundUIButton) {
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ShareSettingsController
        
        var changedUserRole = userRole!
        
        switch roleSegmentedControl.selectedSegmentIndex {
        case 0:
            changedUserRole.role = .read
        case 1:
            changedUserRole.role = .write
        case 2:
            changedUserRole.role = .manage
        default:
            changedUserRole.role = .read
        }
        
        DataStorageClient.shared.editNode(node!, userRole: changedUserRole) { (result) in
            DispatchQueue.main.async {
//                vc.tableView.beginUpdates()
//                vc.userRoles[(self.indexPath?.row)!].role = changedUserRole.role
//                let path = IndexPath(row: 0, section: (self.indexPath?.section)!)
//                vc.tableView.insertRows(at: [path], with: .automatic)
//                vc.tableView.endUpdates()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    

}
