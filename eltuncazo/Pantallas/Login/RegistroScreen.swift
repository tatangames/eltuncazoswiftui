import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

struct RegistroView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var usuario: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var openLoadingSpinner: Bool = false
    @State private var boolCambiarVista = false
    
    @State private var showModal: Bool = false
    @State private var modalMensaje: String = ""
    
    @State private var showModalTitulo: Bool = false
    @State private var modalTitulo: String = ""
    @State private var modalMensajeTitulo: String = ""
    
    @State private var showModal2Botones: Bool = false
    
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = RegistroViewModel()
    
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
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
                        
                        Text("Registro")
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
                    VStack(spacing: 0) {
                        
                        // ── WAVE ─────────────────────────────────
                        Image("icono_wave")
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .offset(y: -1)
                        
                        Spacer().frame(height: 4)
                        
                        // ── CARD ─────────────────────────────────
                        VStack(spacing: 0) {
                            
                            BloqueTextFieldLoginView(
                                text: $usuario,
                                maxLength: 20
                            )
                            
                            Spacer().frame(height: 12)
                            
                            BloqueTextFieldPasswordView(
                                text: $password,
                                isPasswordVisible: $isPasswordVisible,
                                maxLength: 16
                            )
                            
                            Spacer().frame(height: 12)
                            
                            Text("Mínimo 4 caracteres")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                                .padding(.top, 4)
                            
                            Spacer().frame(height: 20)
                            
                            Button(action: {
                                hideKeyboard()
                                validarRegistro()
                            }) {
                                Text("REGISTRARSE")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(colorPrimario)
                                    .cornerRadius(30)
                                    .shadow(color: colorPrimario.opacity(0.4), radius: 6, x: 0, y: 4)
                            }
                            .buttonStyle(NoOpacityChangeButtonStyle())
                            
                            Spacer().frame(height: 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 32)
                    }
                    .padding(.bottom, keyboardHeight)
                }
                .onTapGesture { hideKeyboard() }
            }
            
            // ── MODALES ───────────────────────────────────────────
            if showModal {
                CustomModal1ButtonView(
                    isActive: $showModal,
                    title: "Aviso",
                    message: modalMensaje
                )
                .zIndex(20)
            }
            
            if showModalTitulo {
                CustomModal1ButtonView(
                    isActive: $showModalTitulo,
                    title: modalTitulo,
                    message: modalMensajeTitulo
                )
                .zIndex(20)
            }
            
            if showModal2Botones {
                CustomModal2ButtonsView(
                    isActive: $showModal2Botones,
                    message: "¿Deseas registrarte?",
                    onAccept: {
                        showModal2Botones = false
                        serverRegistro()
                    },
                    labelAceptar: "Sí",
                    labelCancelar: "No"
                )
                .zIndex(20)
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $boolCambiarVista) {
            PrincipalView()
        }
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil, queue: .main
            ) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.16)) { keyboardHeight = frame.height }
                }
            }
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil, queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.16)) { keyboardHeight = 0 }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func validarRegistro() {
        guard !usuario.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensaje = "Usuario es requerido"
            showModal = true
            return
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensaje = "Contraseña es requerida"
            showModal = true
            return
        }
        guard password.count >= 4 else {
            modalMensaje = "Mínimo 4 caracteres"
            showModal = true
            return
        }
        showModal2Botones = true
    }
    
    func serverRegistro() {
        viewModel.registroRX(telefono: usuario, password: password)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    switch success {
                    case 1:
                        modalTitulo = json["titulo"].string ?? ""
                        modalMensajeTitulo = json["mensaje"].string ?? ""
                        showModalTitulo = true
                    case 2:
                        let _id = json["id"].string ?? ""
                        idUsuario = _id
                        boolCambiarVista = true
                    default:
                        mensajeError()
                    }
                case .failure:
                    mensajeError()
                }
            }, onError: { _ in
                mensajeError()
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    func mensajeError() {
        toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
    }
}
