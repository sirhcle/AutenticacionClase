import SwiftUI

/// Estado de la pantalla "Bloqueo al salir de la app" (ejemplo extra del día 8).
///
/// Capa MVVM: **ViewModel**. Decide cuándo se bloquea el contenido (al pasar la app a
/// segundo plano) y lo desbloquea cuando la persona se verifica con `BiometriaManager`.
@MainActor
@Observable
final class BloqueoViewModel {

    // MARK: - Estado

    /// `true` cuando el contenido está tapado y hay que verificarse.
    private(set) var bloqueada = false

    /// Mensaje del último intento de desbloqueo; nil si no hay.
    private(set) var mensaje: String?

    // MARK: - Acciones

    /// La vista llama esto cada vez que cambia la fase de la app (`scenePhase`).
    ///
    /// `ScenePhase` tiene tres valores: `.active` (en uso), `.inactive` (en transición)
    /// y `.background` (fuera de pantalla). Solo bloqueamos en `.background`:
    /// el aviso de Face ID y el Centro de Control también provocan `.inactive`,
    /// y bloquear ahí taparía la app aunque la persona no hubiera salido de ella.
    func cambioDeFase(_ fase: ScenePhase) {
        if fase == .background {
            bloqueada = true
        }
    }

    /// Pide Face ID/Touch ID para quitar el bloqueo.
    func desbloquear() async {
        do {
            try await BiometriaManager.shared.autenticar(motivo: "Desbloquea para volver a tus notas privadas.")
            bloqueada = false
            mensaje = nil
        } catch {
            mensaje = error.localizedDescription
        }
    }
}
