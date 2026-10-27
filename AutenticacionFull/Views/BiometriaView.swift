import SwiftUI

/// Pantalla del ejemplo "Biometría (Face ID)" (día 8).
///
/// Capa MVVM: **View**. Muestra qué biometría tiene el dispositivo, un botón para
/// verificarse y un contenido privado que solo aparece cuando la persona fue reconocida.
/// El sistema pregunta; esta vista solo dibuja el resultado que le da `BiometriaViewModel`.
struct BiometriaView: View {
    // MARK: - Estado

    @State private var viewModel = BiometriaViewModel()

    // MARK: - Cuerpo

    var body: some View {
        Form {
            Section("Dispositivo") {
                Label(viewModel.tipo.nombre, systemImage: viewModel.tipo.icono)

                Button("Revisar de nuevo") {
                    viewModel.revisarDisponibilidad()
                }
            }

            Section("Verificación") {
                Button("Verificar mi identidad") {
                    Task { await viewModel.autenticar() }
                }
                .disabled(!viewModel.puedeAutenticar)

                if let mensaje = viewModel.mensaje {
                    Text(mensaje)
                        .foregroundStyle(viewModel.autenticado ? .green : .red)
                }
            }

            // Este contenido solo se dibuja cuando la persona fue reconocida.
            if viewModel.autenticado {
                Section("Contenido privado") {
                    Label("Saldo ficticio: $12,345.00", systemImage: "banknote")
                    Button("Ocultar") {
                        viewModel.cerrar()
                    }
                }
            }

            if !viewModel.puedeAutenticar {
                Section {
                    Text("En el simulador: menú Features → Face ID → Enrolled. Luego toca \"Revisar de nuevo\". Para responder el aviso usa Matching Face (éxito) o Non-matching Face (fallo).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Biometría")
    }
}

#Preview {
    NavigationStack { BiometriaView() }
}
