//
//  Horse.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 14/12/23.
//

import Foundation

class Horse {
    let name: String
    let price: Int// Ensure this property is mutable
    
    init(name: String, price: Int) {
        self.name = name
        self.price = price
    }
}
