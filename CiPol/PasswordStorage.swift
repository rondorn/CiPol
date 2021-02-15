//
//  PasswordStorage.swift
//  CiPol
//
//  Created by Ron Dorn on 2/12/21.
//

import Foundation
import KeychainSwift

class PasswordStorage {
    
    let keychain = KeychainSwift()

    init(){
        keychain.accessGroup = "ML4263UA5L.com.rdorn.CiPol"
    }
    
    func setPassword(serverName: String, password: String){
    
        keychain.set(password, forKey: serverName)
        
    }
    
    func getPassword(serverName: String)->String{
        
        let keychain = KeychainSwift()
        let password = keychain.get(serverName)
            
        return password ?? ""
    }
    
    
}
