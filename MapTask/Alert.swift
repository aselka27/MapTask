//
//  Alert.swift
//  MapTask
//
//  Created by саргашкаева on 27.02.2023.
//

import UIKit


extension UIViewController {
    
    func alertAddAdress(title: String, placeholder: String, completion: @escaping (String)->()) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { action in
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completion(text)
        }
        alertController.addTextField { tf in
            tf.placeholder = placeholder
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true)
    }
}
