//
//  PreviewManger.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 06.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

import QuickLook

class PreviewManager: NSObject, QLPreviewControllerDataSource {
    
    
    static let shared = PreviewManager()
    
    var file: File?
    
    func previewViewControllerForFile(_ file: File, fromNavigation: Bool) -> UIViewController {
        
//        if file.type == .PLIST || file.type == .JSON{
//            let webviewPreviewViewContoller = WebviewPreviewContoller(nibName: "WebviewPreviewViewContoller", bundle: Bundle(for: WebviewPreviewViewContoller.self))
//            webviewPreviewViewContoller.file = file
//            return webviewPreviewViewContoller
//        }
//        else {
        
            let vc = QLPreviewController()
            vc.hidesBottomBarWhenPushed = true
            vc.dataSource = self
            //self.file = file
//            if fromNavigation == true {
//                return previewTransitionViewController.quickLookPreviewController
//            }
            return vc
        //}
    }
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.file!
    }
    
}



