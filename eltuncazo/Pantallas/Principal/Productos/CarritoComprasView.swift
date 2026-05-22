import SwiftUI
import AlertToast

struct CarritoComprasView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    @StateObject private var viewModel = ListadoCarritoViewModel()
    @StateObject private var viewModelBorrar = BorrarCarritoViewModel()
    @StateObject private var viewModelBorrarProducto = BorrarProductoCarritoViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var productos: [ModeloCarritoTemporal] = []
    @State private var subtotal: String = "0.00"
    @State private var hayProductoNoDisponible: Bool = false
    @State private var hayDireccionRegistrada: Bool = true
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    
    @State private var showModalBorrarCarrito: Bool = false
    @State private var showModalBorrarProducto: Bool = false
    @State private var carritoidAEliminar: Int = 0
    
    let colorPrimario = Color(hex: "#512DA8")
    let colorNaranja = Color(hex: "#F57C00")
    
    var carritoVacio: Bool { productos.isEmpty }
    @State private var irAEnviarOrden: Bool = false
    
    var colorBarra: Color {
        if carritoVacio { return .gray }
        if !hayDireccionRegistrada { return colorNaranja }
        return colorPrimario
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
                        
                        Text("Carrito")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            if datosCargados {
                                if !carritoVacio {
                                    showModalBorrarCarrito = true
                                } else {
                                    toastViewModel.showCustomToast(with: "No hay productos", tipoColor: .gris)
                                }
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 8)
                }
                .frame(height: 56)
                
                // ── CONTENIDO ────────────────────────────────────
                if datosCargados {
                    if carritoVacio {
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .font(.system(size: 72))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Carrito vacío")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(productos, id: \.carritoid) { producto in
                                    NavigationLink(destination:
                                        EditarProductoView(idFilaCarrito: producto.carritoid)
                                            .onDisappear {
                                                datosCargados = false
                                                cargarCarrito()
                                            }
                                    ) {
                                        ItemCarritoView(
                                            producto: producto,
                                            onEditar: { },
                                            onEliminar: {
                                                carritoidAEliminar = producto.carritoid
                                                showModalBorrarProducto = true
                                            }
                                        )
                                        .padding(.horizontal, 12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                Spacer()
            }
            
            // ── BARRA INFERIOR SUBTOTAL ───────────────────────────
            if datosCargados {
                VStack(spacing: 0) {
                    
                    if !carritoVacio && !hayDireccionRegistrada {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Text("Agrega una dirección para continuar")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(colorNaranja)
                    }
                    
                    Button(action: {
                        if carritoVacio { return }
                        if !hayDireccionRegistrada { return }
                        if !hayProductoNoDisponible {
                            // navegar a enviar orden
                            irAEnviarOrden = true
                        }
                    }) {
                        HStack {
                            Text(carritoVacio ? "Carrito vacío" : !hayDireccionRegistrada ? "Toca para agregar dirección" : "Subtotal: $\(subtotal)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            if !carritoVacio {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(colorBarra)
                    }
                    .disabled(carritoVacio)
                    
                    colorBarra
                        .frame(height: 34)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            
            // ── MODAL BORRAR CARRITO ──────────────────────────────
            if showModalBorrarCarrito {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("¿Borrar carrito de compras?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        
                        HStack(spacing: 0) {
                            Button(action: { showModalBorrarCarrito = false }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 50)
                            Button(action: {
                                showModalBorrarCarrito = false
                                serverBorrarCarrito()
                            }) {
                                Text("Sí")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(colorPrimario)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 40)
                }
                .zIndex(20)
            }
            
            // ── MODAL BORRAR PRODUCTO ─────────────────────────────
            if showModalBorrarProducto {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("¿Eliminar este producto?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        
                        HStack(spacing: 0) {
                            Button(action: { showModalBorrarProducto = false }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 50)
                            Button(action: {
                                showModalBorrarProducto = false
                                serverBorrarProducto(carritoid: carritoidAEliminar)
                            }) {
                                Text("Sí")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "#F44336"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 40)
                }
                .zIndex(20)
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onReceive(viewModel.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelBorrar.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelBorrarProducto.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .navigationDestination(isPresented: $irAEnviarOrden) {
            EnviarOrdenView()
        }
        .onAppear { cargarCarrito() }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: { toastViewModel.customToast })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func cargarCarrito() {
        viewModel.listadoCarritoRX(clienteid: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.productos = modelo.producto ?? []
                    self.subtotal = modelo.subtotal ?? "0.00"
                    self.hayProductoNoDisponible = (modelo.estadoProductoGlobal == 1)
                    self.hayDireccionRegistrada = (modelo.hayDireccionRegistrada == 1)
                case 2:
                    self.productos = []
                    self.subtotal = "0.00"
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
    
    func serverBorrarCarrito() {
        viewModelBorrar.borrarCarritoRX(clienteid: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1, 2:
                    self.toastViewModel.showCustomToast(with: "Carrito borrado", tipoColor: .verde)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss()
                    }
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func serverBorrarProducto(carritoid: Int) {
        viewModelBorrarProducto.borrarProductoRX(clienteid: idUsuario, carritoid: carritoid) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Carrito borrado", tipoColor: .verde)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss()
                    }
                case 2, 3:
                    self.toastViewModel.showCustomToast(with: "Producto eliminado", tipoColor: .verde)
                    self.datosCargados = false
                    self.cargarCarrito()
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}

// ── ITEM CARRITO ──────────────────────────────────────────────────
struct ItemCarritoView: View {
    
    let producto: ModeloCarritoTemporal
    let onEditar: () -> Void
    let onEliminar: () -> Void
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        HStack(spacing: 10) {
            
            // Badge cantidad
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#1976D2"))
                    .frame(width: 40, height: 26)
                Text("\(producto.cantidad)x")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Imagen
            Group {
                if producto.utiliza_imagen == 1,
                   let img = producto.imagen, !img.isEmpty {
                    AsyncImage(url: URL(string: "\(baseUrlImagen)\(img)")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .empty:
                            ProgressView()
                        default:
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            
            // Nombre
            Text(producto.nombre ?? "")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Precio
            Text("$\(producto.precio ?? "0.00")")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(minWidth: 60, alignment: .trailing)
            
            // Icono editar (decorativo, el NavigationLink maneja la navegación)
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(colorPrimario)
            
            // Botón eliminar — usa simultaneousGesture para no activar el NavigationLink
            Button(action: { }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#F44336"))
            }
            .simultaneousGesture(TapGesture().onEnded {
                onEliminar()
            })
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
