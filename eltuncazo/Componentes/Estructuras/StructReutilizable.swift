//
//  StructReutilizable.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 18/8/24.
//

import Foundation
import SwiftUI
import AlertToast

// utilizado en login (ejemplo)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// ocultar teclado
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// utilizado en login (ejemplo)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// Animacion cuando el boton es presionado
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0) // Mantener la opacidad al 100% incluso cuando se presiona
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Ejemplo de escala para indicar que está presionado
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}



struct RadioButton: View {
    let id: Int
    let label: String
    @Binding var isSelected: Int
    
    var body: some View {
        Button(action: {
            isSelected = id
        }) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected == id {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10) // Círculo más pequeño
                    }
                }
                Text(label)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}



enum ToastColor {
    case azul
    case verde
    case gris
    case rojo
    
    var color: Color {
        switch self {
        case .azul:
            return AppColors.ColorAzulGob
        case .verde:
            return AppColors.ColorVerde
        case .gris:
            return AppColors.ColorGris1Gob
        case .rojo:
            return AppColors.ColorRojo
        }
    }
}



extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
}


struct BloqueTextFieldPasswordView: View {
    
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    var maxLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Contraseña")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                
                if isPasswordVisible {
                    TextField("Ingresa tu contraseña", text: $text)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .foregroundColor(.black)
                        .onChange(of: text) { newValue in
                            if newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                            }
                        }
                } else {
                    SecureField("Ingresa tu contraseña", text: $text)
                        .foregroundColor(.black)
                        .onChange(of: text) { newValue in
                            if newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                            }
                        }
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
    }
}


struct BloqueTextFieldLoginView: View {
    
    @Binding var text: String
    var maxLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Usuario")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                
                TextField("Ingresa tu usuario", text: $text)
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
}


struct CustomModal2ButtonsView: View {
    
    @Binding var isActive: Bool
    var message: String
    var onAccept: () -> Void
    var labelAceptar: String
    var labelCancelar: String
    
    let colorPrimario = Color(hex: "#512DA8")
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Mensaje
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                
                Divider()
                
                // Botones
                HStack(spacing: 0) {
                    
                    // Cancelar
                    Button(action: {
                        isActive = false
                    }) {
                        Text(labelCancelar)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    
                    Divider()
                        .frame(height: 50)
                    
                    // Aceptar
                    Button(action: {
                        onAccept()
                    }) {
                        Text(labelAceptar)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(colorPrimario)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 40)
        }
    }
}


struct CardCategoriaView: View {
    
    let imagenUrl: String
    let nombre: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                
                // Imagen 16:9
                AsyncImage(url: URL(string: imagenUrl)) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color(hex: "#F5F5F5")
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Color(hex: "#F5F5F5")
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 32))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16/9, contentMode: .fit)
                .clipped()
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        topTrailingRadius: 16
                    )
                )
                
                // Nombre
                Text(nombre)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}




