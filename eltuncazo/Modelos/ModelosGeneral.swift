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


struct ModeloListadoDirecciones: Codable {
    let success: Int
    let estado: Int
    let direcciones: [ModeloDireccionesArray]
}

struct ModeloDireccionesArray: Codable {
    let id: Int
    let id_cliente: Int
    let nombre: String?
    let direccion: String?
    let punto_referencia: String?
    let seleccionado: Int
    let telefono: String?
}
