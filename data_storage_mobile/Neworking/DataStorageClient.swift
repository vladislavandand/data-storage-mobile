//
//  DataStorageClient.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 01.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

let apiVersion = "/api/v0"

class DataStorageClient {
    
    static let shared = DataStorageClient()
    
    private let session = URLSession.shared
    private static let dataStorageURL = "http://storage.dev.shr.phoenixit.ru"
    
    // MARK: - Auth
    
    func auth(username: String, password: String, completion: @escaping (Result<Bool>) -> Void) {
        
        let authString = "user%5Bemail%5D=\(username)&user%5Bpassword%5D=\(password)"
        
        let urlString = DataStorageClient.dataStorageURL + "/auth/sign_in"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        request.allHTTPHeaderFields = headers
        let postData = NSMutableData(data: authString.data(using: String.Encoding.utf8)!)
        request.httpBody = postData as Data
        
        let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completion(Result.failure(err))
                print(err.localizedDescription)
            } else {

                let httpURLResponse = response as? HTTPURLResponse
                let fields = httpURLResponse!.allHeaderFields
                
                let requestMetadata = RequestMetadata(fromHTTPHeaderFields: fields)
                completion(Result.success(true, requestMetadata))
        
            }
        })
        task.resume()
    }
    
    func healthCheck(completion: @escaping (Result<Bool>) -> Void) {
        var urlString = DataStorageClient.dataStorageURL + apiVersion
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completion(Result.failure(err))
                print(err.localizedDescription)
            } else {
                
                let httpURLResponse = response as? HTTPURLResponse
                let fields = httpURLResponse!.allHeaderFields
                let requestMetadata = RequestMetadata(fromHTTPHeaderFields: fields)
                
                if ((httpURLResponse?.statusCode)! < 400) {
                    completion(Result.success(true, requestMetadata))
                } else {
                    completion(Result.success(false, requestMetadata))
                }
                
            }
        })
        task.resume()
    }
    
    // MARK: - Nodes
    
    func addNode(_ name: String, type: NodeType, toParentNode id: Int?, completionHandler: @escaping (Result<Node>) -> Void) {
        
        let parameters = ["node": [
            "name": name,
            "parent_node": id,
            "node_type": type.rawValue,
            ]] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes"
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    func getNodesForTab(tab: Tab, completionHandler: @escaping (Result<Nodes>) -> Void) {
        
        var urlString = ""
        switch tab {
        case .own:
            urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/personal"
        case .share:
            urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/share"
        }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    //let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let nodes = try decoder.decode(Nodes.self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(nodes, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    func getChildNodes(id: Int, completionHandler: @escaping (Result<Nodes>) -> Void) {
    
    let urlString = DataStorageClient.dataStorageURL + apiVersion +
        "/nodes/" + id.description + "/children"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let nodes = try decoder.decode(Nodes.self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(nodes, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    func renameNode(_ node: Node, name: String, completionHandler: @escaping (Result<Node>) -> Void) {
    
        let parameters = [
            "node": [
                "name": name
            ]
        ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }

        
    }
    
    func deleteNode(id: Int, completionHandler: @escaping (Result<Bool>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion +
            "/nodes/" + id.description
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {

                let httpURLResponse = response as? HTTPURLResponse
                let requestMetadata = RequestMetadata(fromHTTPHeaderFields: (httpURLResponse?.allHeaderFields)!)
                completionHandler(Result.success(true, requestMetadata))
            }
        })
        task.resume()
        
        
    }
    
    func copyNode(_ node: Node, toNodeWithId id: Int?, completionHandler: @escaping (Result<Bool>) -> Void) {
        
        var parameters: [String : Any]
        
        if let targetParent = id {
            parameters = [
                "target_parent": id
            ]
        } else {
            parameters = [:]
        }
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)! + "/copy_to"
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    
                    let httpURLResponse = response as? HTTPURLResponse
                    let requestMetadata = RequestMetadata(fromHTTPHeaderFields: (httpURLResponse?.allHeaderFields)!)
                    completionHandler(Result.success(true, requestMetadata))
                    
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    func searchNode(searchText: String, completionHandler: @escaping (Result<[Node]>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion + "/search"
        let url = URL(string: urlString)
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = [URLQueryItem(name: "q", value: searchText)]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let nodes = try decoder.decode(Nodes.self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(nodes, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    // MARK: - Roles
    
    func getUserRoles(id: Int, completionHandler: @escaping (Result<[NodeUserRole]>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion +
            "/nodes/" + id.description + "/user_roles"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let userRoles = try decoder.decode([NodeUserRole].self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(userRoles, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    func getMailingListRoles(id: Int, completionHandler: @escaping (Result<[NodeMailingListRole]>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion +
            "/nodes/" + id.description + "/mailing_list_roles"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let mailingListRoles = try decoder.decode([NodeMailingListRole].self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(mailingListRoles, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    func editNode(_ node: Node, add userRole: NodeUserRole, completionHandler: @escaping (Result<Node>) -> Void) {
        
        let parameters = [
            "node": [
                "node_user_roles_attributes": [[
                    "user_id": userRole.user.id,
                    "full_name": userRole.user.name,
                    "role_type": userRole.role.rawValue
                    ]
                ]]
            ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    func editNode(_ node: Node, add mailingListRole: NodeMailingListRole, completionHandler: @escaping (Result<Node>) -> Void) {
        
        let parameters = [
            "node": [
                "node_mailing_list_roles_attributes": [[
                    "mailing_list_id": mailingListRole.mailingList.id,
                    "full_name": mailingListRole.mailingList.name,
                    "role_type": mailingListRole.role.rawValue,
                    ]
                ]]
            ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    func editNode(_ node: Node, userRole: NodeUserRole, completionHandler: @escaping (Result<Node>) -> Void) {
        let parameters = [
            "node": [
                "node_user_roles_attributes": [[
                    "id": userRole.id,
                    "user_id": userRole.user.id,
                    "full_name": userRole.user.name,
                    "role_type": userRole.role.rawValue,
                    "mayDestroy": userRole.mayDestroy
                    ]
                ]]
            ] as! [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
    }
    
    func editNode(_ node: Node, mailingListRole: NodeMailingListRole, completionHandler: @escaping (Result<Node>) -> Void) {
        
        let parameters = [
            "node": [
                "node_mailing_list_roles_attributes": [[
                    "id": mailingListRole.id,
                    "mailing_list_id": mailingListRole.mailingList.id,
                    "full_name": mailingListRole.mailingList.name,
                    "role_type": mailingListRole.role.rawValue
                    ]]
                ]
            ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    func node(_ node: Node, destroyUserRole role: NodeUserRole, completionHandler: @escaping (Result<Node>) -> Void) {
        let parameters = [
            "node": [
                "node_user_roles_attributes": [[
                    "id": role.id,
                    "user_id": role.user.id,
                    "full_name": role.user.name,
                    "role_type": role.role.rawValue,
                    "mayDestroy": role.mayDestroy,
                    "_destroy": true
                    ]]
                ]
            ] as! [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                            print(node)
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            print("Пойман!", error.localizedDescription)
        }
    }
    
    func node(_ node: Node, destroyMailingListRole role: NodeMailingListRole, completionHandler: @escaping (Result<Node>) -> Void) {
        
        let parameters = [
            "node": [
                "node_mailing_list_roles_attributes": [[
                    "id": role.id,
                    "mailing_list_id": role.mailingList.id,
                    "full_name": role.mailingList.name,
                    "role_type": role.role.rawValue,
                    "_destroy": true
                    ]
                ]]
            ] as [String : Any]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let urlString = DataStorageClient.dataStorageURL + apiVersion + "/nodes/" + (node.id?.description)!
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            let headers = ["Content-Type": "application/json"]
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            
            let task = self.session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    completionHandler(Result.failure(err))
                    print(err.localizedDescription)
                } else {
                    do {
                        if let httpURLResponse = response as? HTTPURLResponse {
                            let decoder = JSONDecoder()
                            let node = try decoder.decode(Node.self, from: data!)
                            let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                          
                            completionHandler(Result.success(node, requestMetadata))
                        }
                    } catch _ {
                        let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                        completionHandler(Result.failure(invalidJSONError))
                        print(response?.description)
                    }
                }
            })
            task.resume()
            
        } catch {
            
        }
        
    }
    
    
    // MARK: - Documents
    
    func loadFile(document: Document, completion: @escaping (Result<File>) -> Void) {

        let downloadURL = URL(string: DataStorageClient.dataStorageURL + document.downloadURL!)
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl?.appendingPathComponent((downloadURL?.lastPathComponent)!)
        
        if FileManager.default.fileExists(atPath: (destinationUrl?.path)!) {
            print("file already exists [\(destinationUrl?.path)]")
            let localFile = File(document: document, previewItemURL: destinationUrl!)
            let meta = RequestMetadata(fromHTTPHeaderFields: [AnyHashable : Any]())
            completion(Result.success(localFile, meta))
            //completion(Result.success(destinationUrl!, nil))
        } else {
            
            var request = URLRequest(url: downloadURL!)
            request.httpMethod = "GET"
            
            let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
                if let err = err {
                    print(err.localizedDescription)
                    completion(Result.failure(err))
                } else {
                    do {
                        try data?.write(to: destinationUrl!, options: .atomicWrite)
                        let httpURLResponse = response as! HTTPURLResponse
                        let file = File(document: document, previewItemURL: destinationUrl!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completion(Result.success(file, requestMetadata))
                    } catch {
                        completion(Result.failure(error))
                    }

                }
            })
            task.resume()
        }
    
    }
    
    
    
    func getUsers(completionHandler: @escaping (Result<[User]>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion + "/users"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let users = try decoder.decode(Users.self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(users, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
        
    }
    
    func getMailingLists(completionHandler: @escaping (Result<[MailingList]>) -> Void) {
        
        let urlString = DataStorageClient.dataStorageURL + apiVersion + "/mailing_lists"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response, err: Error?) -> Void in
            if let err = err {
                completionHandler(Result.failure(err))
                print(err.localizedDescription)
            } else {
                do {
                    if let httpURLResponse = response as? HTTPURLResponse {
                        let decoder = JSONDecoder()
                        let mailingLists = try decoder.decode(MailingLists.self, from: data!)
                        let requestMetadata = RequestMetadata(fromHTTPHeaderFields: httpURLResponse.allHeaderFields)
                        completionHandler(Result.success(mailingLists, requestMetadata))
                    }
                } catch _ {
                    let invalidJSONError = DataStorageIOError.invalidJSON(data!)
                    completionHandler(Result.failure(invalidJSONError))
                    print(response?.description)
                }
            }
        })
        task.resume()
    }
    

    
    
    func deleteNodeMailingList() {
        
    }
    
    
}
