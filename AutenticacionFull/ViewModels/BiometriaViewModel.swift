import SwiftUI

/// Estado de la pantalla "Biometría (Face ID)" (ejemplo del día 8).
///
/// Capa MVVM: **ViewModel**. Guarda qué biometría hay disponible, si la persona ya fue
/// reconocida y el mensaje a mostrar. Para preguntar al sistema usa `BiometriaManager`.
@MainActor
@Observable
final class BiometriaViewModel {

    // MARK: - Estado

    /// Tipo de biometría del dispositivo (o `.ninguna`).
    private(set) var tipo: TipoBiometria = .ninguna

    /// `true` cuando la persona ya fue reconocida.
    private(set) var autenticado = false

    /// Mensaje sobre el último intento; nil si todavía no se ha intentado.
    private(set) var mensaje: String?

    // MARK: - Ciclo de vida

    init() {
        revisarDisponibilidad()
    }

    // MARK: - Propiedades calculadas

    /// ¿Tiene sentido mostrar el botón de verificar?
    var puedeAutenticar: Bool { tipo != .ninguna }

    // MARK: - Acciones

    /// Vuelve a preguntar qué biometría hay. Útil en el simulador:
    /// activas "Enrolled" en el menú Features y revisas de nuevo sin reiniciar la app.
    func revisarDisponibilidad() {
        tipo = BiometriaManager.shared.tipoDisponible()
    }

    /// Pide la verificación y actualiza el resultado.
    func autenticar() async {
        autenticado = false
        do {
            try await BiometriaManager.shared.autenticar(motivo: "Confirma que eres tú para ver el contenido privado.")
            autenticado = true
            mensaje = "¡Identidad confirmada!"
        } catch {
            mensaje = error.localizedDescription
        }
    }

    /// Vuelve a ocultar el contenido privado.
    func cerrar() {
        autenticado = false
        mensaje = nil
    }
}
