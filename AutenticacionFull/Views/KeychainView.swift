import SwiftUI

/// Pantalla del ejemplo "Keychain: guardar el token" (día 8).
///
/// Capa MVVM: **View**. Tiene un campo para escribir un token, tres botones
/// (guardar, leer, borrar) y muestra el token guardado con casi todo oculto.
/// Toda la lógica está en `KeychainViewModel`.
struct KeychainView: View {
    // MARK: - Estado

    @State private var viewModel = KeychainViewModel()

    // MARK: - Cuerpo

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section("Guardar") {
                SecureField("Escribe un token", text: $viewModel.tokenNuevo)
                Button("Guardar en el Keychain") {
                    viewModel.guardar()
                }
            }

            Section("En el Keychain") {
                // `if let` abre el opcional: el texto se dibuja solo si hay un token.
                if let oculto = viewModel.tokenOculto {
                    Text(oculto)
                        .font(.system(.body, design: .monospaced))
                } else {
                    Text("No hay ningún token guardado.")
                        .foregroundStyle(.secondary)
                }

                Button("Leer de nuevo") {
                    viewModel.leer()
                }
                Button("Borrar", role: .destructive) {
                    viewModel.borrar()
                }
                // Si no hay token, no tiene sentido borrar.
                .disabled(viewModel.tokenGuardado == nil)
            }

            if let mensaje = viewModel.mensaje {
                Section {
                    Text(mensaje)
                }
            }

            Section {
                Text("Guarda un token, detén la app en Xcode y vuelve a ejecutarla: el token sigue ahí. Con una variable normal o con @State se perdería.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keychain")
    }
}

#Preview {
    NavigationStack { KeychainView() }
}
