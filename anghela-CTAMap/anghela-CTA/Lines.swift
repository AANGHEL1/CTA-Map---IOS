//
//  Lines.swift
//  anghela-CTA
//
//  Created by Ana Anghel on 5/4/21.
//



let lines = [
    Line(name: "Red Line", type: .red),
    Line(name: "Blue Line", type: .blue),
    Line(name: "Brown Line", type: .brown),
    Line(name: "Green Line", type: .green),
    Line(name: "Orange Line", type: .orange),
    Line(name: "Purple Line", type: .purple),
    Line(name: "Pink Line", type: .pink),
    Line(name: "Yellow Line", type: .yellow)
]

import Foundation


class Line {
    enum `Type`: String {
        case red = "Red Line"
        case blue = "Blue Line"
        case brown = "Brown Line"
        case green = "Green Line"
        case orange = "Orange Line"
        case purple = "Purple Line"
        case pink = "Pink Line"
        case yellow = "Yellow Line"
    }
    
    var name: String
    var type: Type
    init(name: String, type: Type) {
        self.name = name
        self.type = type
        
    }
}
