import SwiftUI
import AlertToast

struct ElegirProductoView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    let idProducto: Int
    
    @StateObject private var viewModel = InformacionProductoViewModel()
    @StateObject private var viewModelEnviar = EnviarProductoCarritoViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var producto: ModeloInformacionProductoArray? = nil
    @State private var cantidad: Int = 1
    @State private var notaInput: String = ""
    @State private var errorNotaObligatoria: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var showModalNota: Bool = false
    @State private var notaMensaje: String = ""
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var precioUnit: Double {
        Double(producto?.precio ?? "0") ?? 0.0
    }
    
    var total: Double {
        precioUnit * Double(cantidad)
    }
    
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
                        
                        Text("Elegir Cantidad")
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
                if let prod = producto {
                    ScrollView {
                        VStack(spacing: 0) {
                            
                            // Imagen
                            if prod.utiliza_imagen == 1,
                               let img = prod.imagen, !img.isEmpty {
                                AsyncImage(url: URL(string: "\(baseUrlImagen)\(img)")) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    case .empty:
                                        ProgressView()
                                    case .failure:
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.white)
                            }
                            
                            // ── CARD INFO ─────────────────────────
                            VStack(alignment: .leading, spacing: 12) {
                                
                                // Nombre
                                Text(prod.nombre ?? "")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(colorPrimario)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Descripción
                                if let desc = prod.descripcion, !desc.isEmpty {
                                    Text(desc
                                        .replacingOccurrences(of: "\\r\\n", with: "\n")
                                        .replacingOccurrences(of: "\\n", with: "\n"))
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "#444444"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineSpacing(4)
                                }
                                
                                // Precio unitario
                                HStack(spacing: 4) {
                                    Text("Precio:")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                    Text(formatearUSD(precioUnit))
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(colorPrimario)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            
                            // ── CARD CANTIDAD ─────────────────────
                            VStack(spacing: 12) {
                                Text("Cantidad")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 0) {
                                    Spacer()
                                    
                                    Button(action: {
                                        if cantidad > 1 { cantidad -= 1 }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(cantidad > 1 ? colorPrimario : Color.gray.opacity(0.3))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "minus")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .disabled(cantidad <= 1)
                                    
                                    Text("\(cantidad)")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(width: 70)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        if cantidad < 50 { cantidad += 1 }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(cantidad < 50 ? colorPrimario : Color.gray.opacity(0.3))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "plus")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .disabled(cantidad >= 50)
                                    
                                    Spacer()
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 10)
                            
                            // ── CARD NOTAS ────────────────────────
                            VStack(alignment: .leading, spacing: 10) {
                                
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(colorPrimario)
                                    Text("Notas")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    TextField("", text: $notaInput, axis: .vertical)
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                        .lineLimit(3...6)
                                        .placeholder(when: notaInput.isEmpty) {
                                            Text("Escribe una nota para este producto...")
                                                .foregroundColor(.gray.opacity(0.6))
                                                .font(.system(size: 15))
                                        }
                                        .padding(12)
                                        .onChange(of: notaInput) { val in
                                            errorNotaObligatoria = false
                                            if val.count > 100 {
                                                notaInput = String(val.prefix(100))
                                            }
                                        }
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(notaInput.count)/100")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 12)
                                            .padding(.bottom, 8)
                                    }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            errorNotaObligatoria ? Color.red : Color.gray.opacity(0.25),
                                            lineWidth: 1
                                        )
                                )
                                
                                if errorNotaObligatoria {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.red)
                                        Text("Nota es requerida")
                                            .font(.system(size: 12))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 10)
                            
                            // ── TOTAL + BOTON ─────────────────────
                            VStack(spacing: 16) {
                                
                                HStack {
                                    Text("Total")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(formatearUSD(total))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorPrimario)
                                }
                                
                                Button(action: {
                                    if prod.utiliza_nota == 1 && notaInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                        errorNotaObligatoria = true
                                        notaMensaje = prod.nota ?? "Nota requerida"
                                        showModalNota = true
                                        return
                                    }
                                    serverAgregarCarrito()
                                }) {
                                    Text("AGREGAR A LA ORDEN")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(colorPrimario)
                                        .cornerRadius(12)
                                        .shadow(color: colorPrimario.opacity(0.4), radius: 6, x: 0, y: 3)
                                }
                                .buttonStyle(NoOpacityChangeButtonStyle())
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 10)
                            
                            Spacer().frame(height: 32)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            
            // ── MODAL NOTA REQUERIDA ──────────────────────────────
            if showModalNota {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("Nota Requerida")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        
                        Text(notaMensaje)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Button(action: { showModalNota = false }) {
                            Text("Aceptar")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorPrimario)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
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
        .navigationBarHidden(true)
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onReceive(viewModelEnviar.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onAppear {
            cargarProducto()
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func cargarProducto() {
        viewModel.informacionProductoRX(idProducto: idProducto) { result in
            switch result {
            case .success(let modelo):
                if modelo.success == 1, let first = modelo.producto.first {
                    self.producto = first
                } else {
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func serverAgregarCarrito() {
        viewModelEnviar.enviarProductoRX(
            clienteid: idUsuario,
            productoid: idProducto,
            cantidad: cantidad,
            nota: notaInput.trimmingCharacters(in: .whitespaces)
        ) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Agregado al carrito", tipoColor: .verde)
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
    
    func formatearUSD(_ monto: Double) -> String {
        return String(format: "$%.2f", monto)
    }
}

// ── EXTENSION PLACEHOLDER ─────────────────────────────────────────
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

