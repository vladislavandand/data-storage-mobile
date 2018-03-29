//
//  NodeCreationViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 11.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class NodeCreationViewController: UITableViewController {

    @IBOutlet weak var nodeNameTextField: UITextField!
    @IBOutlet weak var nodeTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var confirmButton: RoundUIButton!
    
    var parentNodeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nodeNameTextField.becomeFirstResponder()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "addNode" {
//            currentNode = sender as? Node
//        }
//     }
    
    @IBAction func confirmButtonAction(_ sender: RoundUIButton) {
        //self.navigationController?.popViewController(animated: true)
        
        let index = nodeTypeSegmentedControl.selectedSegmentIndex
        
        let type: NodeType = index == 0 ? .document : .folder
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ExplorerViewController
        
        guard nodeNameTextField.text!.count > 0 else {
            let alertController = UIAlertController(title: "Название должно быть заполнено", message:
                "Введите хотя бы один символ", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        DataStorageClient.shared.addNode(nodeNameTextField.text!, type: type, toParentNode: parentNodeId) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let node,let meta):
                    
                    print("NODE IS ADDED")
                    
                    DispatchQueue.main.async {
                        
                        
                        vc.tableView.beginUpdates()
                        vc.nodes.insert(node, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        vc.tableView.insertRows(at: [indexPath], with: .automatic)
                        vc.tableView.endUpdates()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let err):
                     print("NODE IS NOT ADDED ERROR")
                     print(err)
                }
            }
        }
    }
    
}
