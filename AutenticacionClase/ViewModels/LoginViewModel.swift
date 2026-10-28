import SwiftUI

/// Estado de la pantalla "Login y sesión en el Keychain" (ejemplo del día 8).
///
/// Capa MVVM: **ViewModel**. Guarda lo que escribe el usuario, si está cargando,
/// el mensaje de error y la sesión abierta. Usa `AutenticacionManager` para validar
/// las credenciales y `KeychainManager` para guardar el token, de modo que la sesión
/// siga abierta aunque el usuario cierre la app.
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

    /// `true` mientras revisamos si ya había un token guardado al abrir la pantalla.
    /// Empieza en `true` para no mostrar el formulario un instante antes de saberlo.
    private(set) var restaurando = true

    /// Texto del último error; nil si no hay ninguno.
    private(set) var mensajeError: String?

    /// La sesión abierta; nil mientras nadie haya iniciado sesión.
    private(set) var sesion: Sesion?

    /// Nombre bajo el que guardamos el token dentro del Keychain.
    private let cuentaToken = "tokenSesion"

    // MARK: - Propiedades calculadas

    /// ¿Se puede intentar el inicio de sesión? Solo si ambos campos tienen algo.
    /// Es una propiedad calculada: se recalcula cada vez que alguien la lee.
    var formularioValido: Bool {
        !correo.trimmingCharacters(in: .whitespaces).isEmpty && !contrasena.isEmpty
    }

    // MARK: - Acciones

    /// Pide al Manager iniciar sesión, guarda el token en el Keychain y abre la sesión.
    func iniciarSesion() async {
        // `guard` sale de la función si no se cumple la condición:
        // evita enviar un formulario vacío o dos intentos a la vez.
        guard formularioValido, !cargando else { return }

        cargando = true
        mensajeError = nil

        do {
            let nueva = try await AutenticacionManager.shared.iniciarSesion(
                correo: correo,
                contrasena: contrasena
            )
            // Guardamos el token ANTES de abrir la sesión: si el Keychain falla,
            // saltamos al `catch` y la sesión no se abre.
            try KeychainManager.shared.guardar(nueva.token, cuenta: cuentaToken)
            sesion = nueva
            // Por seguridad, la contraseña no se queda en memoria una vez usada.
            contrasena = ""
        } catch {
            mensajeError = error.localizedDescription
        }

        cargando = false
    }

    /// Busca un token guardado y, si existe y es válido, abre la sesión sin pedir datos.
    /// La vista lo llama cada vez que aparece la pantalla.
    func restaurarSesion() async {
        // `defer` ejecuta su contenido justo antes de salir de la función,
        // sin importar por cuál `return` o error se salga.
        defer { restaurando = false }

        // Si ya hay una sesión abierta, no hay nada que restaurar.
        guard sesion == nil else { return }

        do {
            // `leer` devuelve nil si no hay token: entonces se queda el formulario.
            guard let token = try KeychainManager.shared.leer(cuenta: cuentaToken) else { return }
            sesion = try await AutenticacionManager.shared.restaurarSesion(token: token)
        } catch {
            // El token no sirvió (inválido o el Keychain falló): lo borramos para no insistir.
            // `try?` intenta la operación y, si falla, ignora el error en lugar de lanzarlo.
            try? KeychainManager.shared.borrar(cuenta: cuentaToken)
            mensajeError = error.localizedDescription
        }
    }

    /// Cierra la sesión: borra el token del Keychain y limpia el formulario.
    func cerrarSesion() {
        do {
            // Primero borramos el token; si no se pudiera borrar, la sesión volvería
            // a abrirse sola la próxima vez, así que en ese caso no la cerramos.
            try KeychainManager.shared.borrar(cuenta: cuentaToken)
            sesion = nil
            correo = ""
            contrasena = ""
            mensajeError = nil
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
