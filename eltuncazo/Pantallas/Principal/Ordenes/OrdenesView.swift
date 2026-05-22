import SwiftUI
import AlertToast

struct OrdenesView: View {
    
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    @StateObject private var viewModel = ListadoOrdenesViewModel()
    @StateObject private var viewModelOcultar = OcultarOrdenViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var ordenes: [ModeloOrdenesArray] = []
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    
    @State private var irAEstadoOrden: Bool = false
    @State private var ordenIdSeleccionada: Int = 0
    
    let colorPrimario = Color(hex: "#512DA8")
    let colorVerde = Color(hex: "#4CAF50")
    let colorRojo = Color(hex: "#F44336")
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F0E8")
                .ignoresSafeArea()
            
            if datosCargados {
                if ordenes.isEmpty {
                    // ── VACÍO ─────────────────────────────────────
                    ScrollView {
                        // ScrollView necesario para que refreshable funcione en lista vacía
                        VStack(spacing: 16) {
                            Spacer().frame(height: 100)
                            Image(systemName: "cart")
                                .font(.system(size: 72))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No tienes órdenes")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                            Text("Tus pedidos aparecerán aquí")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .refreshable {
                        await refreshOrdenes()
                    }
                } else {
                    // ── LISTA ─────────────────────────────────────
                    List {
                        ForEach(ordenes, id: \.id) { orden in
                            CardOrdenView(
                                orden: orden,
                                colorPrimario: colorPrimario,
                                colorVerde: colorVerde,
                                colorRojo: colorRojo,
                                onVerOrden: {
                                    ordenIdSeleccionada = orden.id
                                    irAEstadoOrden = true
                                },
                                onBorrarOrden: {
                                    serverOcultarOrden(ordenid: orden.id)
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await refreshOrdenes()
                    }
                }
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationDestination(isPresented: $irAEstadoOrden) {
            EstadoOrdenView(idOrden: ordenIdSeleccionada)
           
        }
        .onReceive(viewModel.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelOcultar.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onAppear { cargarOrdenes() }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: { toastViewModel.customToast })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func cargarOrdenes() {
        viewModel.listadoOrdenesRX(clienteid: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.ordenes = modelo.ordenes ?? []
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
    
    // 👇 Usa withCheckedContinuation para que el refreshable espere la respuesta
    func refreshOrdenes() async {
        await withCheckedContinuation { continuation in
            viewModel.listadoOrdenesRX(clienteid: idUsuario) { result in
                switch result {
                case .success(let modelo):
                    switch modelo.success {
                    case 1:
                        self.ordenes = modelo.ordenes ?? []
                    default:
                        break
                    }
                case .failure:
                    break
                }
                continuation.resume()
            }
        }
    }
    
    func serverOcultarOrden(ordenid: Int) {
        viewModelOcultar.ocultarOrdenRX(ordenid: ordenid) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.cargarOrdenes()
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}

// ── CARD ORDEN ────────────────────────────────────────────────────
struct CardOrdenView: View {
    
    let orden: ModeloOrdenesArray
    let colorPrimario: Color
    let colorVerde: Color
    let colorRojo: Color
    let onVerOrden: () -> Void
    let onBorrarOrden: () -> Void
    
    var esCancelada: Bool { orden.estado_cancelada == 1 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("#Orden: \(orden.id)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            if let fecha = orden.fecha_orden {
                Text("Fecha: \(fecha)")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            
            if let total = orden.total {
                Text("Total: \(total)")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            
            if let direccion = orden.direccion {
                Text("Dirección: \(direccion)")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            
            if let estado = orden.estado {
                Text("Estado: \(estado)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            if let nota = orden.nota_orden, !nota.isEmpty {
                Text("Nota: \(nota)")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
            }
            
            if esCancelada, let msg = orden.mensaje_cancelado, !msg.isEmpty {
                Text("Cancelada: \(msg)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorRojo)
            }
            
            HStack {
                Spacer()
                Button(action: {
                    if esCancelada {
                        onBorrarOrden()
                    } else {
                        onVerOrden()
                    }
                }) {
                    Text(esCancelada ? "Borrar orden" : "Ver orden")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(esCancelada ? colorRojo : colorVerde)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}
