//
//  MenuPrincipalView.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

struct MenuPrincipalView: View {
    
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    @StateObject private var viewModel = ListadoMenuPrincipalViewModel()
    @State private var categorias: [ModeloMenuPrincipalCategoriasArray] = []
    @State private var openLoadingSpinner: Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    
    // Navegación a productos
    @State private var irAProductos: Bool = false
    @State private var idCategoriaSeleccionada: Int = 0
    @State private var nombreCategoriaSeleccionada: String = ""
    
    let navController: (Int, String) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F0E8")
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(categorias, id: \.id) { categoria in
                        let imagenUrl = "\(baseUrlImagen)\(categoria.imagen ?? "")"
                        
                        CardCategoriaView(
                            imagenUrl: imagenUrl,
                            nombre: categoria.nombre ?? ""
                        ) {
                            idCategoriaSeleccionada = categoria.id
                            nombreCategoriaSeleccionada = categoria.nombre ?? ""
                            irAProductos = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.top, 8)
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onAppear {
            cargarMenu()
        }
        .navigationDestination(isPresented: $irAProductos) {
            ListadoProductosView(
                idCategoria: idCategoriaSeleccionada,
                nombreCategoria: nombreCategoriaSeleccionada
            )
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    func cargarMenu() {
        viewModel.listadoMenuPrincipalRX(id: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.categorias = modelo.servicios
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}
