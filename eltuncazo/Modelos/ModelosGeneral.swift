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


struct ModeloListadoProductos: Codable {
    let success: Int
    let productos: [ModeloProductosArray]
}

struct ModeloProductosArray: Codable {
    let id: Int
    let id_bloque_servicios: Int
    let nombre: String?
    let posicion: Int?
    let activo: Int
    let productos: [ModeloProductosTerceraArray]
}

struct ModeloProductosTerceraArray: Codable {
    let id: Int
    let id_categorias: Int
    let nombre: String?
    let imagen: String?
    let descripcion: String?
    let precio: String?
    let activo: Int
    let posicion: Int?
    let utiliza_nota: Int
    let nota: String?
    let utiliza_imagen: Int
}






struct ModeloInformacionProducto: Codable {
    let success: Int
    let producto: [ModeloInformacionProductoArray] // 👈 "producto" no "informacion_producto"
}

struct ModeloInformacionProductoArray: Codable {
    let id: Int
    let id_categorias: Int
    let nombre: String?
    let imagen: String?
    let descripcion: String?
    let precio: String?
    let activo: Int
    let posicion: Int?
    let utiliza_nota: Int
    let nota: String?
    let utiliza_imagen: Int
}


struct ModeloDatosBasicos: Codable {
    let success: Int
    let mensaje: String?
}

struct ModeloCarrito: Codable {
    let success: Int
    let subtotal: String?
    let estadoProductoGlobal: Int?
    let producto: [ModeloCarritoTemporal]?
    let hayDireccionRegistrada: Int?
}

struct ModeloCarritoTemporal: Codable {
    let productoID: Int
    let nombre: String?
    let cantidad: Int
    let imagen: String?
    let precio: String?
    let activo: Int
    let carritoid: Int
    let utiliza_imagen: Int
}


struct ModeloInformacionProductoEditar: Codable {
    let success: Int
    let producto: ModeloInformacionProductoEditarArray?
}

struct ModeloInformacionProductoEditarArray: Codable {
    let productoID: Int
    let nombre: String?
    let descripcion: String?
    let cantidad: Int
    let nota_producto: String?
    let imagen: String?
    let precio: String?
    let utiliza_nota: Int
    let nota: String?
    let utiliza_imagen: Int
}


struct ModeloInformacionOrdenParaEnviar: Codable {
    let success: Int
    let total: String?
    let cliente: String?
    let direccion: String?
    let minimo: Int?
    let mensaje: String?
}

struct ModeloListadoOrdenes: Codable {
    let success: Int
    let ordenes: [ModeloOrdenesArray]?
    let vacio: Int?
}

struct ModeloOrdenesArray: Codable {
    let id: Int
    let fecha_orden: String?
    let direccion: String?
    let total: String?
    let estado: String?
    let nota_orden: String?
    let estado_cancelada: Int
    let mensaje_cancelado: String?
}
