//
//  PrincipalScreen.swift
//  eltuncazo
//
//  Created by Jonathan on 21/5/26.
//

import SwiftUI

struct PrincipalView: View {
    
    @State private var selectedTab: String = "menu"
    @State private var irACarrito: Bool = false
    @State private var canClickCart: Bool = true
    
    @State private var irAPerfil: Bool = false
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    
                    // ── TOOLBAR SUPERIOR ─────────────────────────
                  
                    ZStack {
                        colorPrimario
                            .ignoresSafeArea(edges: .top)
                        
                        HStack {
                            Spacer()
                            
                            Text("El Tuncazo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        // Icono persona solo cuando está en menú
                        if selectedTab == "menu" {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                     irAPerfil = true
                                }) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 8)
                            }
                        }
                    }
                    .frame(height: 56)
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    // ── CONTENIDO ────────────────────────────────
                    Group {
                        switch selectedTab {
                        case "menu":
                            MenuPrincipalView { id, nombre in
                                // navegar a productos
                            }
                        case "ordenes":
                            OrdenesView()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.bottom, 60)
                
                // ── BOTTOM BAR PERSONALIZADO ─────────────────────
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
                        .frame(height: 60)
                    
                    HStack(spacing: 0) {
                        
                        // Tab Menú
                        Button(action: { selectedTab = "menu" }) {
                            VStack(spacing: 2) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 20))
                                Text("Menú")
                                    .font(.system(size: 11, weight: selectedTab == "menu" ? .bold : .regular))
                            }
                            .foregroundColor(selectedTab == "menu" ? colorPrimario : .gray)
                            .frame(maxWidth: .infinity)
                        }
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                        
                        // Tab Órdenes
                        Button(action: { selectedTab = "ordenes" }) {
                            VStack(spacing: 2) {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 20))
                                Text("Órdenes")
                                    .font(.system(size: 11, weight: selectedTab == "ordenes" ? .bold : .regular))
                            }
                            .foregroundColor(selectedTab == "ordenes" ? colorPrimario : .gray)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 60)
                    
                    // FAB centrado
                    Button(action: {
                        guard canClickCart else { return }
                        canClickCart = false
                        irACarrito = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            canClickCart = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                            
                            Image(systemName: "cart.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "#448AFF"))
                        }
                    }
                    .offset(y: -20)
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $irACarrito) {
                CarritoComprasView()
            }
            .navigationDestination(isPresented: $irAPerfil) {
                 PerfilView()
            }
        }
    }
}


