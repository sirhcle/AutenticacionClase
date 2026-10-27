import SwiftUI

/// Estado de la pantalla "Login con sesión simulada" (ejemplo del día 8).
///
/// Capa MVVM: **ViewModel**. Guarda lo que escribe el usuario, si está cargando,
/// el mensaje de error y la sesión abierta. Para validar las credenciales usa `AutenticacionManager`.
@MainActor
@Observable
final class LoginViewModel {

    // MARK: - Estado

    /// Lo que escribe el usuario. La vista los conecta a los campos con `@Bindable`,
    /// por eso son `var` normales y no `private(set)`.
    var correo = ""
    var contrasena = ""

    /// `true` mientras esperamos la respuesta del "servidor".
    /// `private(set)`: la vista puede leerla, pero solo esta clase puede cambiarla.
    private(set) var cargando = false

    /// Texto del último error; nil si no hay ninguno.
    private(set) var mensajeError: String?

    /// La sesión abierta; nil mientras nadie haya iniciado sesión.
    private(set) var sesion: Sesion?

    // MARK: - Propiedades calculadas

    /// ¿Se puede intentar el inicio de sesión? Solo si ambos campos tienen algo.
    /// Es una propiedad calculada: se recalcula cada vez que alguien la lee.
    var formularioValido: Bool {
        !correo.trimmingCharacters(in: .whitespaces).isEmpty && !contrasena.isEmpty
    }

    /// ¿Hay una sesión abierta?
    var haySesion: Bool { sesion != nil }

    // MARK: - Acciones

    /// Pide al Manager iniciar sesión y guarda el resultado.
    func iniciarSesion() async {
        // `guard` sale de la función si no se cumple la condición:
        // evita enviar un formulario vacío o dos intentos a la vez.
        guard formularioValido, !cargando else { return }

        cargando = true
        mensajeError = nil

        do {
            sesion = try await AutenticacionManager.shared.iniciarSesion(
                correo: correo,
                contrasena: contrasena
            )
            // Por seguridad, la contraseña no se queda en memoria una vez usada.
            contrasena = ""
        } catch {
            mensajeError = error.localizedDescription
        }

        cargando = false
    }

    /// Cierra la sesión: olvida la sesión y limpia el formulario.
    func cerrarSesion() {
        sesion = nil
        correo = ""
        contrasena = ""
        mensajeError = nil
    }
}
