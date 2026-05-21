//
//  CambioPasswordView.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast


struct ActualizarPasswordView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    @StateObject private var viewModel = ActualizarPasswordViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var openLoadingSpinner: Bool = false
    
    @State private var showModal1Boton: Bool = false
    @State private var modalMensaje: String = ""
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
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
                        
                        Text("Actualizar Contraseña")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                            .padding(.trailing, 16)
                    }
                    .padding(.top, 8)
                }
                .frame(height: 56)
                
                // ── CONTENIDO ────────────────────────────────────
                ScrollView {
                    VStack(spacing: 0) {
                        
                        Card {
                            VStack(spacing: 0) {
                                
                                Spacer().frame(height: 6)
                                
                                Text("Actualizar")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Spacer().frame(height: 15)
                                
                                BloqueTextFieldPasswordView(
                                    text: $password,
                                    isPasswordVisible: $isPasswordVisible,
                                    maxLength: 16
                                )
                                .padding(.horizontal, 16)
                                
                                Spacer().frame(height: 6)
                                
                                Button(action: {
                                    hideKeyboard()
                                    validar()
                                }) {
                                    Text("ACTUALIZAR")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(colorPrimario)
                                        .cornerRadius(25)
                                        .shadow(color: colorPrimario.opacity(0.4), radius: 6, x: 0, y: 4)
                                }
                                .buttonStyle(NoOpacityChangeButtonStyle())
                                .padding(.top, 32)
                                .padding(.horizontal, 24)
                                
                                Spacer().frame(height: 10)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.bottom, keyboardHeight)
            }
            
            // ── MODALES ───────────────────────────────────────────
            if showModal1Boton {
                CustomModal1ButtonView(
                    isActive: $showModal1Boton,
                    title: "Aviso",
                    message: modalMensaje
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
    
    func validar() {
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensaje = "Contraseña es requerida"
            showModal1Boton = true
            return
        }
        guard password.count >= 4 else {
            modalMensaje = "Mínimo 4 caracteres"
            showModal1Boton = true
            return
        }
        serverActualizar()
    }
    
    func serverActualizar() {
        viewModel.actualizarPasswordRX(id: idUsuario, password: password) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Actualizado", tipoColor: .verde)
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}

// ── CARD HELPER ───────────────────────────────────────────────────
struct Card<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}






