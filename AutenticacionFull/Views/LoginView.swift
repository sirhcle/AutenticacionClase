import SwiftUI

/// Pantalla del ejemplo "Login con sesión simulada" (día 8).
///
/// Capa MVVM: **View**. Muestra el formulario cuando no hay sesión y los datos de la sesión cuando sí la hay.
/// No valida nada: solo avisa a `LoginViewModel` lo que pasa y dibuja su estado.
struct LoginView: View {
    // MARK: - Estado

    @State private var viewModel = LoginViewModel()

    // MARK: - Cuerpo

    var body: some View {
        Form {
            // `if let` abre el opcional: si `sesion` tiene valor, lo usamos con el nombre `sesion`.
            if let sesion = viewModel.sesion {
                sesionAbierta(sesion)
            } else {
                formulario
            }
        }
        .navigationTitle("Login")
    }

    // MARK: - Partes de la pantalla

    /// Lo que se ve cuando ya hay una sesión.
    private func sesionAbierta(_ sesion: Sesion) -> some View {
        Section("Sesión abierta") {
            LabeledContent("Nombre", value: sesion.usuario.nombre)
            LabeledContent("Correo", value: sesion.usuario.correo)
            // `prefix(8)` toma solo el inicio del token: nunca lo enseñes completo.
            LabeledContent("Token", value: String(sesion.token.prefix(8)) + "…")

            Button("Cerrar sesión", role: .destructive) {
                viewModel.cerrarSesion()
            }
        }
    }

    /// El formulario de inicio de sesión.
    /// `@ViewBuilder` permite declarar el `@Bindable` y después devolver las vistas.
    @ViewBuilder
    private var formulario: some View {
        // Necesario para poder escribir `$viewModel.correo` (un binding) más abajo.
        @Bindable var viewModel = viewModel

        Section("Credenciales") {
            TextField("Correo", text: $viewModel.correo)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textContentType(.username)

            // SecureField oculta lo que se escribe con puntos.
            SecureField("Contraseña", text: $viewModel.contrasena)
                .textContentType(.password)
        }

        Section {
            // `Task { }` abre un espacio donde se puede usar `await`,
            // porque el cierre del botón no es asíncrono.
            Button {
                Task { await viewModel.iniciarSesion() }
            } label: {
                if viewModel.cargando {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Iniciar sesión")
                        .frame(maxWidth: .infinity)
                }
            }
            // Se desactiva si faltan datos o si ya está cargando.
            .disabled(!viewModel.formularioValido || viewModel.cargando)

            // Solo se dibuja si hay un error.
            if let error = viewModel.mensajeError {
                Text(error)
                    .foregroundStyle(.red)
            }
        } footer: {
            Text("Usuario de prueba: alumno@unam.mx · Contraseña: swift2026")
        }
    }
}

#Preview {
    NavigationStack { LoginView() }
}
