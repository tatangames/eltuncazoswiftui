import SwiftUI
import AlertToast

struct ListadoProductosOrdenView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let idOrden: Int
    
    @StateObject private var viewModel = ListadoProductosOrdenViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var productos: [ModeloProductosDeOrdenArray] = []
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F0E8")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // ── TOOLBAR ──────────────────────────────────────
                ZStack {
                    colorPrimario.ignoresSafeArea(edges: .top)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)
                        Spacer()
                        Text("Productos")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .padding(.trailing, 16)
                    }
                    .padding(.top, 8)
                }
                .frame(height: 56)
                
                // ── CONTENIDO ────────────────────────────────────
                if !datosCargados {
                    // Spinner dentro del área de contenido, debajo del toolbar
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: colorPrimario))
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if productos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cart")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No hay productos")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(productos, id: \.productoID) { producto in
                                    ProductoOrdenCardView(producto: producto)
                                        .padding(.horizontal, 12)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onAppear { cargarProductos() }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: { toastViewModel.customToast })
    }
    
    func cargarProductos() {
        viewModel.listadoProductosRX(ordenid: idOrden) { result in
            switch result {
            case .success(let modelo):
                if modelo.success == 1 {
                    self.productos = modelo.productos ?? []
                } else {
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

// ── CARD PRODUCTO ORDEN ───────────────────────────────────────────
struct ProductoOrdenCardView: View {
    
    let producto: ModeloProductosDeOrdenArray
    let colorPrimario = Color(hex: "#512DA8")
    let colorRojo = Color(hex: "#D32F2F")
    let imageSlot: CGFloat = 96
    
    var traeImagen: Bool {
        guard producto.utiliza_imagen == 1 else { return false }
        guard let img = producto.imagen, !img.isEmpty else { return false }
        return true
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text(producto.nombre ?? "")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("Precio: $\(producto.precio ?? "0.00")")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Cantidad: \(producto.cantidad)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Total: \(producto.multiplicado ?? "")")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                if let nota = producto.nota, !nota.isEmpty {
                    Text("Nota: \(nota)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(colorRojo)
                }
            }
            .padding(14)
            .padding(.trailing, imageSlot)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                if traeImagen {
                    AsyncImage(url: URL(string: "\(baseUrlImagen)\(producto.imagen ?? "")")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .empty:
                            ProgressView()
                        case .failure:
                            Image(systemName: "camera.fill").foregroundColor(.gray)
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
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1.5))
                }
            }
            .frame(width: 72, height: 72)
            .padding(.trailing, 12)
        }
        .frame(minHeight: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
