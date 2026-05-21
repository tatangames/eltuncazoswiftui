import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

struct LoginView: View {
    
    @State private var usuario: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var openLoadingSpinner: Bool = false
    @State private var boolCambiarVista = false
    @State private var showModal: Bool = false
    @State private var modalMensaje: String = ""
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = LoginViewModel()
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // ── BLOQUE SUPERIOR MORADO ──────────────────
                        ZStack(alignment: .center) {
                            colorPrimario
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                            
                            VStack {
                                Spacer().frame(height: 32)
                                
                                // Logo circular blanco
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 130, height: 130)
                                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                                    
                                    Image("logoapp")
                                          .resizable()
                                          .scaledToFit()
                                          .frame(width: 130, height: 130)
                                          .clipShape(Circle())
                                          .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                        
                        // ── TÍTULO ───────────────────────────────────
                        Text("Cafe, Helados Y Pupuseria El Tuncazo")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        Spacer().frame(height: 16)
                        
                        // ── CARD LOGIN ───────────────────────────────
                        VStack(spacing: 16) {
                            
                            // Campo usuario
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Usuario")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                    
                                    TextField("Ingresa tu usuario", text: $usuario)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .foregroundColor(.black)
                                }
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Campo contraseña
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Contraseña")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                    
                                    if isPasswordVisible {
                                        TextField("Ingresa tu contraseña", text: $password)
                                            .autocapitalization(.none)
                                            .autocorrectionDisabled()
                                            .foregroundColor(.black)
                                    } else {
                                        SecureField("Ingresa tu contraseña", text: $password)
                                            .foregroundColor(.black)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            Spacer().frame(height: 8)
                            
                            // Botón iniciar sesión
                            Button(action: {
                                hideKeyboard()
                                validarYLogin()
                            }) {
                                Text("INICIAR SESIÓN")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(colorPrimario)
                                    .cornerRadius(30)
                                    .shadow(color: colorPrimario.opacity(0.4), radius: 6, x: 0, y: 4)
                            }
                            .buttonStyle(NoOpacityChangeButtonStyle())
                            
                            Spacer().frame(height: 4)
                            
                            // Registrarse
                            Button(action: {
                                // navegar a registro
                            }) {
                                Text("Registrarse")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(colorPrimario)
                                    .frame(maxWidth: .infinity)
                            }
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
                
                // Modal 1 botón
                if showModal {
                    CustomModal1ButtonView(
                        isActive: $showModal,
                        title: "Aviso",
                        message: modalMensaje
                    )
                    .zIndex(20)
                }
                
                // Spinner
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .navigationDestination(isPresented: $boolCambiarVista) {
                // PrincipalView()
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
            .background(Color.white)
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func validarYLogin() {
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
        serverLogin()
    }
    
    func serverLogin() {
        viewModel.loginRX(telefono: usuario, password: password)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    switch success {
                    case 1:
                        boolCambiarVista = true
                    default:
                        modalMensaje = "Datos incorrectos"
                        showModal = true
                    }
                case .failure(_):
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

// ── EXTENSION COLOR HEX ──────────────────────────────────────────
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
