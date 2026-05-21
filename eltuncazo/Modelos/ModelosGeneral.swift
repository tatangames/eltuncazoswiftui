//
//  ModelosGeneral.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//
import Foundation


struct ModeloMenuPrincipal: Codable {
    let success: Int
    let servicios: [ModeloMenuPrincipalCategoriasArray]
}

struct ModeloMenuPrincipalCategoriasArray: Codable {
    let id: Int
    let nombre: String?
    let imagen: String?
    let posicion: Int?
    let activo: Int
}
