//
//  ListadoProductosView.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

struct ListadoProductosView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let idCategoria: Int
    let nombreCategoria: String
    
    @StateObject private var viewModel = ListadoProductosViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var categorias: [ModeloProductosArray] = []
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    
    // Agrega estos estados
    @State private var irAProducto: Bool = false
    @State private var idProductoSeleccionado: Int = 0
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F0E8")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // ── TOOLBAR ──────────────────────────────────────
                ZStack {
                    colorPrimario
                        .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Text(nombreCategoria)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .padding(.trailing, 16)
                    }
                    .padding(.top, 8)
                }
                .frame(height: 56)
                
                // ── CONTENIDO ────────────────────────────────────
                if datosCargados {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(categorias, id: \.id) { categoria in
                                
                                // Header de categoría
                                CategoriaHeaderView(title: categoria.nombre ?? "")
                                    .padding(.horizontal, 12)
                                    .padding(.top, 4)
                                
                                // Productos de la categoría
                                ForEach(categoria.productos, id: \.id) { producto in
                                    ProductoItemCardView(producto: producto) {
                                        idProductoSeleccionado = producto.id
                                         irAProducto = true
                                    }
                                    .padding(.horizontal, 12)
                                }
                            }
                            
                            Spacer().frame(height: 20)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .navigationDestination(isPresented: $irAProducto) {
            ElegirProductoView(idProducto: idProductoSeleccionado)
        }
        .onAppear {
            cargarProductos()
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    func cargarProductos() {
        viewModel.listadoProductosRX(idCategoria: idCategoria) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.categorias = modelo.productos
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
                self.datosCargados = true
            case .failure:
                self.datosCargados = true
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}

// ── HEADER CATEGORÍA ──────────────────────────────────────────────
struct CategoriaHeaderView: View {
    
    let title: String
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(colorPrimario)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(colorPrimario)
                .frame(height: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

// ── CARD PRODUCTO ─────────────────────────────────────────────────
struct ProductoItemCardView: View {
    
    let producto: ModeloProductosTerceraArray
    let onClick: () -> Void
    
    let colorPrimario = Color(hex: "#512DA8")
    let imageSlot: CGFloat = 96
    
    var traeImagen: Bool {
        guard producto.utiliza_imagen == 1 else { return false }
        guard let img = producto.imagen, !img.isEmpty else { return false }
        return true
    }
    
    var imagenUrl: String {
        "\(baseUrlImagen)\(producto.imagen ?? "")"
    }
    
    var body: some View {
        Button(action: onClick) {
            ZStack(alignment: .trailing) {
                
                // Texto lado izquierdo
                VStack(alignment: .leading, spacing: 6) {
                    Text(producto.nombre ?? "")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                                      
                    if let precio = producto.precio, !precio.isEmpty {
                        Text("$\(precio)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(colorPrimario)
                    }
                }
                .padding(12)
                .padding(.trailing, imageSlot)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Imagen lado derecho
                Group {
                    if traeImagen {
                        AsyncImage(url: URL(string: imagenUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                }
                .frame(width: 72, height: 72)
                .padding(.trailing, 10)
            }
            .frame(minHeight: 110)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
