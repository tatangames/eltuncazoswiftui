import SwiftUI
import AlertToast

struct EnviarOrdenView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    @StateObject private var viewModel = InformacionOrdenParaEnviarViewModel()
    @StateObject private var viewModelEnviar = EnviarOrdenFinalViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    
    @State private var totalString: String = ""
    @State private var clienteString: String = ""
    @State private var direccionString: String = ""
    @State private var minimoInt: Int = 0
    @State private var mensajeMinimoString: String = ""
    @State private var nota: String = ""
    
    @State private var showModal2Botones: Bool = false
    @State private var showModalRespuesta: Bool = false
    @State private var modalTitulo: String = ""
    @State private var modalMensaje: String = ""
    @State private var showModalFinal: Bool = false
    @State private var modalTituloFinal: String = ""
    @State private var modalMensajeFinal: String = ""
    @State private var irAOrdenes: Bool = false
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var versionApp: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
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
                        
                        Text("Enviar Orden")
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
                if datosCargados {
                    ScrollView {
                        VStack(spacing: 0) {
                            
                            // ── FILA TOTAL ────────────────────────
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                                Text(totalString)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1.5)
                                .padding(.horizontal, 12)
                            
                            // ── CARD MINIMO CONSUMO ───────────────
                            if minimoInt == 0 {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Mínimo de Consumo")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text(mensajeMinimoString)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: "#E9E6EB"))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                                .padding(.horizontal, 12)
                                .padding(.top, 16)
                            }
                            
                            // ── CARD DIRECCION ENTREGA ────────────
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dirección de Entrega")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Cliente")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                    Text(clienteString)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dirección")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                    Text(direccionString)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#E9E6EB"))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                            
                            // ── DIVIDER ───────────────────────────
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1.5)
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                            
                            // ── NOTA ──────────────────────────────
                            VStack(alignment: .leading, spacing: 10) {
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(colorPrimario)
                                    Text("Nota para la orden")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                Text("Ej: tocar timbre...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    TextField("", text: $nota, axis: .vertical)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .lineLimit(3...5)
                                        .placeholder(when: nota.isEmpty) {
                                            Text("Escribe aquí tu nota...")
                                                .foregroundColor(.gray.opacity(0.6))
                                                .font(.system(size: 16))
                                        }
                                        .padding(12)
                                        .onChange(of: nota) { val in
                                            if val.count > 300 { nota = String(val.prefix(300)) }
                                        }
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(nota.count)/300")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 12)
                                            .padding(.bottom, 8)
                                    }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            
            // ── BOTÓN CONFIRMAR FIJO ABAJO ────────────────────────
            if datosCargados {
                VStack {
                    Spacer()
                    Button(action: {
                        hideKeyboard()
                        if minimoInt == 0 {
                            toastViewModel.showCustomToast(with: "Mínimo de compra es requerido", tipoColor: .gris)
                        } else {
                            showModal2Botones = true
                        }
                    }) {
                        Text("CONFIRMAR ORDEN")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(colorPrimario)
                            .cornerRadius(28)
                    }
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
            
            // ── MODAL CONFIRMAR ENVIO ─────────────────────────────
            if showModal2Botones {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("¿Enviar orden?")
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        HStack(spacing: 0) {
                            Button(action: { showModal2Botones = false }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 50)
                            Button(action: {
                                showModal2Botones = false
                                serverEnviarOrden()
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
            
            // ── MODAL RESPUESTA ERROR ─────────────────────────────
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
                        Button(action: { showModalRespuesta = false }) {
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
            
            // ── MODAL ORDEN ENVIADA ───────────────────────────────
            if showModalFinal {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text(modalTituloFinal)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        Text(modalMensajeFinal)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        Button(action: {
                            showModalFinal = false
                            irAOrdenes = true
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
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onReceive(viewModelEnviar.$loadingSpinner) { loading in openLoadingSpinner = loading }
        .onAppear { cargarInformacion() }
        .navigationDestination(isPresented: $irAOrdenes) {
            OrdenesView()
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: { toastViewModel.customToast })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func cargarInformacion() {
        viewModel.informacionOrdenRX(clienteid: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Sin dirección registrada", tipoColor: .gris)
                case 2:
                    self.totalString = modelo.total ?? ""
                    self.clienteString = modelo.cliente ?? ""
                    self.direccionString = modelo.direccion ?? ""
                    self.minimoInt = modelo.minimo ?? 0
                    self.mensajeMinimoString = modelo.mensaje ?? ""
                case 3:
                    self.toastViewModel.showCustomToast(with: "No hay carrito de compras", tipoColor: .gris)
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
    
    func serverEnviarOrden() {
        viewModelEnviar.enviarOrdenRX(
            clienteid: idUsuario,
            nota: nota.trimmingCharacters(in: .whitespaces),
            version: versionApp
        ) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.modalTitulo = "Nota"
                    self.modalMensaje = modelo.mensaje ?? "Cerrado"
                    self.showModalRespuesta = true
                case 2:
                    self.modalTitulo = "Aviso"
                    self.modalMensaje = modelo.mensaje ?? "Cerrado"
                    self.showModalRespuesta = true
                case 3:
                    self.modalTitulo = "Aviso"
                    self.modalMensaje = modelo.mensaje ?? "Mínimo de consumo requerido"
                    self.showModalRespuesta = true
                case 5:
                    self.modalTituloFinal = "¡Orden Enviada!"
                    self.modalMensajeFinal = "Tu orden ha sido enviada correctamente."
                    self.showModalFinal = true
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}
