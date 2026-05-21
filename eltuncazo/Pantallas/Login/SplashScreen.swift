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
               // PrincipalView()
            }
        } else {
            Color.white
                .ignoresSafeArea()
                .onAppear {
                    // pequeño delay para que AppStorage cargue el valor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isReady = true
                    }
                }
        }
    }
}
