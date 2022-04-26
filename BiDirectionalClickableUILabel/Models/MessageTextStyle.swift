//
//  MessageTextStyle.swift
//  BiDirectionalUILabel
//
//  Created by zigzag on 26/4/2022.
//

import Foundation
class MessageTextStyle {
    init(value: String , offset: Int , length : Int , type: Int){
        self.value = value
        self.offset = offset
        self.length = length
        self.type = type
    }
    var value : String = ""
    var offset : Int = 0
    var length : Int = 0
    var type : Int = 0
    init(){
        
    }
}
