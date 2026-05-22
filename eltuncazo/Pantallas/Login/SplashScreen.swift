//
//  SplashScreen.swift
//  eltuncazo
//
//  Created by Jonathan on 20/5/26.
//
import SwiftUI

struct SplashScreenView: View {
    
    @AppStorage(DatosGuardadosKeys.idCliente) private var id: String = ""
    @State private var isReady = false
    
    var body: some View {
        if isReady {
            if id.isEmpty {
                LoginView()
            } else {
                PrincipalView()
            }
        } else {
            Color.white
                .ignoresSafeArea()
                .onAppear {
                    migrateIfNeeded()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isReady = true
                    }
                }
        }
    }
    
    // SI QUIERO OTRO CIERRE FORZADO, CAMBIAR A hasMigratedV3
    func migrateIfNeeded() {
        let hasMigrated = UserDefaults.standard.bool(forKey: "hasMigratedV2")
        if !hasMigrated {
            // Limpiar sesión la primera vez que corre esta versión
            id = ""
            UserDefaults.standard.set(true, forKey: "hasMigratedV2")
        }
    }
}
