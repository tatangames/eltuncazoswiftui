import SwiftUI
import SwiftyJSON
import RxSwift
import AlertToast

struct MisDireccionesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage(DatosGuardadosKeys.idCliente) private var idUsuario: String = ""
    @StateObject private var viewModel = ListadoDireccionesViewModel()
    @StateObject private var registroViewModel = RegistroNuevaDireccionViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var direcciones: [ModeloDireccionesArray] = []
    @State private var datosCargados: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var showBottomSheet: Bool = false
    
    @State private var nombre: String = ""
    @State private var telefono: String = ""
    @State private var direccion: String = ""
    @State private var puntoReferencia: String = ""
    
    @State private var showModalSheet: Bool = false
    @State private var modalMensajeSheet: String = ""
    
    // Confirmar seleccionar
    @State private var showModalSeleccionar: Bool = false
    @State private var direccionSeleccionada: ModeloDireccionesArray? = nil
    
    // Confirmar eliminar
    @State private var showModalEliminar: Bool = false
    @State private var direccionAEliminar: ModeloDireccionesArray? = nil
    
    let colorPrimario = Color(hex: "#512DA8")
    let colorRojo = Color(hex: "#F44336")
    
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
                        
                        Text("Mis Direcciones")
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
                ZStack {
                    
                    if direcciones.isEmpty && datosCargados {
                        VStack(spacing: 12) {
                            Image(systemName: "map")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No hay dirección registrada")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    if !direcciones.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(direcciones, id: \.id) { item in
                                    CardDireccionView(
                                        direccion: item,
                                        onSeleccionar: {
                                            direccionSeleccionada = item
                                            showModalSeleccionar = true
                                        },
                                        onEliminar: {
                                            direccionAEliminar = item
                                            showModalEliminar = true
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                }
                                Spacer().frame(height: 80)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // ── FAB ───────────────────────────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showBottomSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(colorRojo)
                                .frame(width: 56, height: 56)
                                .shadow(color: colorRojo.opacity(0.4), radius: 8, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
            }
            
            // ── MODAL CONFIRMAR SELECCIONAR ───────────────────────
            if showModalSeleccionar {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("¿Seleccionar esta dirección?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                showModalSeleccionar = false
                                direccionSeleccionada = nil
                            }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 50)
                            
                            Button(action: {
                                showModalSeleccionar = false
                                if let dir = direccionSeleccionada {
                                    serverSeleccionarDireccion(dirid: dir.id)
                                }
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
            
            // ── MODAL CONFIRMAR ELIMINAR ──────────────────────────
            if showModalEliminar {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("¿Eliminar esta dirección?")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                showModalEliminar = false
                                direccionAEliminar = nil
                            }) {
                                Text("No")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 50)
                            
                            Button(action: {
                                showModalEliminar = false
                                if let dir = direccionAEliminar {
                                    serverEliminarDireccion(dirid: dir.id)
                                }
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
        .onReceive(registroViewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onAppear {
            cargarDirecciones()
        }
        .sheet(isPresented: $showBottomSheet) {
            bottomSheetNuevaDireccion
        }
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
    }
    
    // ── BOTTOM SHEET ──────────────────────────────────────────────
    var bottomSheetNuevaDireccion: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Nueva Dirección")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)
                        .padding(.bottom, 20)
                    
                    Text("Nombre")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.bottom, 4)
                    
                    BloqueEntradaGeneralView(
                        text: $nombre,
                        placeholder: "Nombre",
                        icono: "person.fill",
                        maxLength: 100,
                        keyboardType: .default
                    )
                    
                    Spacer().frame(height: 12)
                    
                    Text("Teléfono")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.bottom, 4)
                    
                    BloqueEntradaGeneralView(
                        text: $telefono,
                        placeholder: "Teléfono",
                        icono: "number",
                        maxLength: 8,
                        keyboardType: .phonePad
                    )
                    
                    Spacer().frame(height: 12)
                    
                    Text("Dirección")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.bottom, 4)
                    
                    BloqueEntradaGeneralView(
                        text: $direccion,
                        placeholder: "Dirección",
                        icono: "map.fill",
                        maxLength: 400,
                        keyboardType: .default
                    )
                    
                    Spacer().frame(height: 12)
                    
                    HStack(spacing: 6) {
                        Text("Punto de Referencia")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        Text("(Opcional)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 4)
                    
                    BloqueEntradaGeneralView(
                        text: $puntoReferencia,
                        placeholder: "Punto de referencia",
                        icono: "house.fill",
                        maxLength: 400,
                        keyboardType: .default
                    )
                    
                    Spacer().frame(height: 24)
                    
                    Button(action: {
                        hideKeyboard()
                        validarNuevaDireccion()
                    }) {
                        Text("GUARDAR")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(colorPrimario)
                            .cornerRadius(30)
                            .shadow(color: colorPrimario.opacity(0.4), radius: 6, x: 0, y: 4)
                    }
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    
                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
            }
            
            if showModalSheet {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("Aviso")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        
                        Text(modalMensajeSheet)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Button(action: { showModalSheet = false }) {
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
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // ── FUNCIONES ────────────────────────────────────────────────
    
    func validarNuevaDireccion() {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensajeSheet = "Nombre es requerido"
            showModalSheet = true
            return
        }
        guard !telefono.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensajeSheet = "Teléfono es requerido"
            showModalSheet = true
            return
        }
        guard telefono.count == 8 else {
            modalMensajeSheet = "Teléfono debe tener 8 dígitos"
            showModalSheet = true
            return
        }
        guard !direccion.trimmingCharacters(in: .whitespaces).isEmpty else {
            modalMensajeSheet = "Dirección es requerida"
            showModalSheet = true
            return
        }
        serverRegistrarDireccion()
    }
    
    func serverRegistrarDireccion() {
        registroViewModel.registrarDireccionRX(
            id: idUsuario,
            nombre: nombre,
            telefono: telefono,
            direccion: direccion,
            puntoReferencia: puntoReferencia
        ) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    self.nombre = ""
                    self.telefono = ""
                    self.direccion = ""
                    self.puntoReferencia = ""
                    self.showBottomSheet = false
                    self.toastViewModel.showCustomToast(with: "Dirección registrada", tipoColor: .verde)
                    self.cargarDirecciones()
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func serverSeleccionarDireccion(dirid: Int) {
        viewModel.seleccionarDireccionRX(id: idUsuario, dirid: dirid) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Dirección seleccionada", tipoColor: .verde)
                    self.cargarDirecciones()
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func serverEliminarDireccion(dirid: Int) {
        viewModel.eliminarDireccionRX(id: idUsuario, dirid: dirid) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    self.toastViewModel.showCustomToast(with: "Dirección eliminada", tipoColor: .verde)
                    self.cargarDirecciones()
                case 2:
                    self.toastViewModel.showCustomToast(with: "No puedes eliminar la única dirección", tipoColor: .gris)
                default:
                    self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
                }
            case .failure:
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
    
    func cargarDirecciones() {
        viewModel.listadoDireccionesRX(id: idUsuario) { result in
            switch result {
            case .success(let modelo):
                switch modelo.success {
                case 1:
                    self.direcciones = modelo.direcciones
                default:
                    break
                }
                self.datosCargados = true
            case .failure:
                self.datosCargados = true
                self.toastViewModel.showCustomToast(with: "Error, intentar de nuevo", tipoColor: .gris)
            }
        }
    }
}

// ── CARD DIRECCION ────────────────────────────────────────────────
struct CardDireccionView: View {
    
    let direccion: ModeloDireccionesArray
    let onSeleccionar: () -> Void
    let onEliminar: () -> Void
    
    let colorPrimario = Color(hex: "#512DA8")
    let colorRojo = Color(hex: "#F44336")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Nombre + badge principal
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(colorPrimario)
                
                Text(direccion.nombre ?? "")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                if direccion.seleccionado == 1 {
                    Text("Principal")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(colorPrimario)
                        .cornerRadius(8)
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Dirección
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "map.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .frame(width: 18)
                Text(direccion.direccion ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            // Punto referencia
            if let ref = direccion.punto_referencia, !ref.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .frame(width: 18)
                    Text(ref)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            
            // Teléfono
            if let tel = direccion.telefono, !tel.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .frame(width: 18)
                    Text(tel)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Botones acción
            HStack(spacing: 12) {
                
                // Seleccionar - solo si NO está seleccionada
                if direccion.seleccionado != 1 {
                    Button(action: onSeleccionar) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Seleccionar")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(colorPrimario)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(colorPrimario.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Eliminar - siempre visible
                Button(action: onEliminar) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                        Text("Eliminar")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(colorRojo)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(colorRojo.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

// ── CAMPO ENTRADA GENERAL ─────────────────────────────────────────
struct BloqueEntradaGeneralView: View {
    
    @Binding var text: String
    var placeholder: String
    var icono: String
    var maxLength: Int
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(.black)
                .onChange(of: text) { newValue in
                    if newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
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
}
