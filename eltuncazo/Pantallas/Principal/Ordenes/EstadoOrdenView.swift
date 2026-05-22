import SwiftUI
import AlertToast

struct EstadoOrdenView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let idOrden: Int
    
    @StateObject private var viewModel = InformacionOrdenViewModel()
    @StateObject private var viewModelCancelar = CancelarOrdenViewModel()
    @StateObject private var viewModelCompletar = CompletarOrdenViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var orden: ModeloOrdenesIndividualArray? = nil
    @State private var openLoadingSpinner: Bool = false
    
    @State private var showModalCancelar: Bool = false
    @State private var showModalCompletar: Bool = false
    @State private var showModalRespuesta: Bool = false
    @State private var modalTitulo: String = ""
    @State private var modalMensaje: String = ""
    
    @State private var irAProductos: Bool = false
    
    let colorPrimario = Color(hex: "#512DA8")
    let colorVerde = Color(hex: "#2E7D32")
    let colorRojo = Color(hex: "#D32F2F")
    let colorAzul = Color(hex: "#1565C0")
    
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
                        Text("Estado de Orden")
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
                ScrollView {
                    if let ord = orden {
                        VStack(alignment: .leading, spacing: 18) {
                            
                            // Botones Productos + Cancelar
                            HStack(spacing: 12) {
                                Button(action: { irAProductos = true }) {
                                    Text("Productos")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 46)
                                        .background(colorAzul)
                                        .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if ord.estado_iniciada == 0 && ord.estado_cancelada == 0 {
                                    Button(action: { showModalCancelar = true }) {
                                        Text("Cancelar")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 46)
                                            .background(colorRojo)
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("Estado")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                            
                            // Estado iniciada
                            EstadoItemView(
                                titulo: ord.estado_iniciada == 1
                                    ? (ord.texto_iniciada?.isEmpty == false ? ord.texto_iniciada! : "Orden iniciada")
                                    : "Esperando iniciar orden",
                                activo: ord.estado_iniciada == 1,
                                fecha: ord.estado_iniciada == 1 ? ord.fecha_estimada_txt : nil,
                                colorActivo: colorVerde
                            )
                            
                            // ── BOTÓN COMPLETAR ───────────────────
                            if ord.estado_iniciada == 1 || ord.estado_cancelada == 1 {
                                Button(action: { showModalCompletar = true }) {
                                    Text("Completar Orden")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: UIScreen.main.bounds.width * 0.65)
                                        .frame(height: 46)
                                        .background(colorVerde)
                                        .cornerRadius(14)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            // ── ESTADO CANCELADA ──────────────────
                            if ord.estado_cancelada == 1 {
                                EstadoItemView(
                                    titulo: "Cancelada",
                                    activo: true,
                                    fecha: ord.fecha_cancelada,
                                    colorActivo: colorRojo
                                )
                                
                                if let nota = ord.mensaje_cancelada, !nota.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(colorRojo)
                                            .font(.system(size: 16))
                                        Text(nota)
                                            .font(.system(size: 15))
                                            .foregroundColor(colorRojo)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(colorRojo.opacity(0.08))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .refreshable {
                    await refreshOrden()
                }
            }
            
            // ── MODAL CANCELAR ────────────────────────────────────
            if showModalCancelar {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("¿Cancelar orden?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        HStack(spacing: 0) {
                            Button(action: { showModalCancelar = false }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 50)
                            Button(action: {
                                showModalCancelar = false
                                serverCancelar()
                            }) {
                                Text("Sí")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(colorRojo)
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
            
            // ── MODAL COMPLETAR ───────────────────────────────────
            if showModalCompletar {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("¿Finalizar esta orden?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        HStack(spacing: 0) {
                            Button(action: { showModalCompletar = false }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 50)
                            Button(action: {
                                showModalCompletar = false
                                serverCompletar()
                            }) {
                                Text("Sí")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(colorVerde)
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
            
            // ── MODAL RESPUESTA ───────────────────────────────────
            if showModalRespuesta {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text(modalTitulo)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        Text(modalMensaje)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        Button(action: {
                            showModalRespuesta = false
                            cargarOrden()
                        }) {
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
                LoadingSpinnerView().transition(.opacity).zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $irAProductos) {
            ListadoProductosOrdenView(idOrden: idOrden)
        }
        .onReceive(viewModel.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelCancelar.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelCompletar.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onAppear { cargarOrden() }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: { toastViewModel.customToast })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func cargarOrden() {
        viewModel.informacionOrdenRX(ordenid: idOrden) { result in
            switch result {
            case .success(let modelo):
                if modelo.success == 1 {
                    self.orden = modelo.ordenes?.first
                } else {
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func refreshOrden() async {
        await withCheckedContinuation { continuation in
            viewModel.informacionOrdenRX(ordenid: idOrden) { result in
                if case .success(let modelo) = result, modelo.success == 1 {
                    self.orden = modelo.ordenes?.first
                }
                continuation.resume()
            }
        }
    }
    
    func serverCancelar() {
        viewModelCancelar.cancelarOrdenRX(ordenid: idOrden) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.modalTitulo = modelo.titulo ?? "Nota"
                    self.modalMensaje = modelo.mensaje ?? ""
                    self.showModalRespuesta = true
                case 2:
                    self.toastViewModel.showCustomToast(with: "Orden cancelada", tipoColor: .verde)
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
    
    func serverCompletar() {
        viewModelCompletar.completarOrdenRX(ordenid: idOrden) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Orden completada", tipoColor: .verde)
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
}

// ── ESTADO ITEM ───────────────────────────────────────────────────
struct EstadoItemView: View {
    
    let titulo: String
    let activo: Bool
    var fecha: String? = nil
    var colorActivo: Color = Color(hex: "#2E7D32")
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(activo ? colorActivo : Color.gray.opacity(0.4))
                .frame(width: 14, height: 14)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(.system(size: 17, weight: activo ? .semibold : .regular))
                    .foregroundColor(activo ? .black : Color(hex: "#616161"))
                
                if let fecha = fecha, !fecha.isEmpty {
                    Text(fecha)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
}
