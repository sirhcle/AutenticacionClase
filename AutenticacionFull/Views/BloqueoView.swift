import SwiftUI

/// Pantalla del ejemplo extra "Bloqueo al salir de la app" (día 8).
///
/// Capa MVVM: **View**. Muestra unas notas privadas. Cuando la app pasa a segundo plano
/// las tapa con una pantalla de bloqueo y pide Face ID para volver a verlas.
///
/// Ojo: `scenePhase` se lee en la vista con `@Environment`, porque ese valor lo da SwiftUI
/// y solo existe dentro de una vista. Ella no decide nada: se lo pasa a
/// `BloqueoViewModel.cambioDeFase`, y el ViewModel es quien llama a `BiometriaManager`.
struct BloqueoView: View {
    // MARK: - Estado

    @State private var viewModel = BloqueoViewModel()

    /// Fase actual de la app, que SwiftUI actualiza solo.
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Cuerpo

    var body: some View {
        // ZStack apila vistas: lo último que se escribe queda encima.
        ZStack {
            notas

            if viewModel.bloqueada {
                pantallaDeBloqueo
            }
        }
        .navigationTitle("Notas privadas")
        // `onChange` se ejecuta cada vez que `scenePhase` cambia.
        // Recibe el valor anterior y el nuevo; aquí solo necesitamos el nuevo.
        .onChange(of: scenePhase) { _, nueva in
            viewModel.cambioDeFase(nueva)
        }
    }

    // MARK: - Partes de la pantalla

    /// El contenido que queremos proteger.
    private var notas: some View {
        List {
            Section("Notas") {
                Text("Contraseña del wifi de la oficina")
                Text("Idea para la app del diplomado")
                Text("Cita médica del jueves")
            }
            Section {
                Text("Prueba: manda la app a segundo plano (Cmd + Shift + H en el simulador) y vuelve a abrirla.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// La capa que tapa las notas mientras la app está bloqueada.
    private var pantallaDeBloqueo: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
            Text("Contenido bloqueado")
                .font(.title2)

            Button("Desbloquear") {
                Task { await viewModel.desbloquear() }
            }
            .buttonStyle(.borderedProminent)

            if let mensaje = viewModel.mensaje {
                Text(mensaje)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // El fondo opaco es lo que realmente tapa las notas.
        .background(.background)
    }
}

#Preview {
    NavigationStack { BloqueoView() }
}
