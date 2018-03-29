//
//  NodeRenameController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 26.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class NodeRenameController: UITableViewController {

    @IBOutlet weak var nodeNameTextField: UITextField!
    @IBOutlet weak var confirmButton: RoundUIButton!
    
    var node: Node?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeNameTextField.text = node?.name
        nodeNameTextField.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func confirmButtonAction(_ sender: RoundUIButton) {
        
        let vcIndex = self.navigationController?.viewControllers.index(of: self)
        let vc = self.navigationController?.viewControllers[vcIndex! - 1] as! ExplorerViewController
        
        guard let node = self.node else {
            print("Node rename. Node is not passed")
            return
        }
        
        guard let indexPath = self.indexPath else {
            print("Node rename. indexPath is not passed")
            return
        }
        
        guard nodeNameTextField.text!.count > 0 else {
            let alertController = UIAlertController(title: "Название должно быть заполнено", message:
                "Введите хотя бы один символ", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        DataStorageClient.shared.renameNode(node, name: nodeNameTextField.text!) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let node,let meta):
                    
                    print("NODE IS RENAMED")
                    
                    DispatchQueue.main.async {
                        
                        
                        vc.tableView.beginUpdates()
                        vc.nodes[indexPath.row].name = self.nodeNameTextField.text!
                        vc.tableView.reloadRows(at: [indexPath], with: .automatic)
                        vc.tableView.endUpdates()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let err):
                    print("NODE IS NOT RENAMED ERROR")
                    print(err)
                }
            }
        }
    }

}
