//
//  PerfilView.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

enum OpcionPerfil: CaseIterable {
    case direcciones
    case cambioPassword
    case cerrarSesion
    
    var titulo: String {
        switch self {
        case .direcciones:    return "Direcciones"
        case .cambioPassword: return "Cambio de Contraseña"
        case .cerrarSesion:   return "Cerrar Sesión"
        }
    }
    
    var icono: String {
        switch self {
        case .direcciones:    return "list.number"
        case .cambioPassword: return "lock.rotation"
        case .cerrarSesion:   return "rectangle.portrait.and.arrow.right"
        }
    }
}

struct PerfilView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    
    @State private var showModalCerrarSesion: Bool = false
    @State private var irACambioPassword: Bool = false
    @State private var irALogin: Bool = false
    @State private var irADirecciones: Bool = false
    
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
                        
                        Text("Perfil")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Balanceo visual
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                            .padding(.trailing, 16)
                    }
                    .padding(.top, 8)
                }
                .frame(height: 56)
                
                // ── LISTA OPCIONES ────────────────────────────────
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(OpcionPerfil.allCases, id: \.self) { opcion in
                            Button(action: {
                                switch opcion {
                                case .direcciones:
                                        irADirecciones = true
                                case .cambioPassword:
                                    irACambioPassword = true
                                case .cerrarSesion:
                                    showModalCerrarSesion = true
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: opcion.icono)
                                        .font(.system(size: 22))
                                        .foregroundColor(.black)
                                        .frame(width: 32)
                                    
                                    Text(opcion.titulo)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
            
            // ── MODAL CERRAR SESION ───────────────────────────────
            if showModalCerrarSesion {
                CustomModal2ButtonsView(
                    isActive: $showModalCerrarSesion,
                    message: "¿Deseas cerrar sesión?",
                    onAccept: {
                        showModalCerrarSesion = false
                        cerrarSesion()
                    },
                    labelAceptar: "Sí",
                    labelCancelar: "No"
                )
                .zIndex(20)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $irACambioPassword) {
            // CambioPasswordView()
        }
        .navigationDestination(isPresented: $irALogin) {
            LoginView()
        }
        .navigationDestination(isPresented: $irADirecciones) {
            // DireccionesView()
        }
    }
    
    func cerrarSesion() {
        idUsuario = ""
        irALogin = true
    }
}
