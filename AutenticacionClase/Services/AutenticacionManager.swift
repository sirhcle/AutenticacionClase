import Foundation

// MARK: - Errores

/// Los motivos por los que un inicio de sesión puede fallar.
///
/// - `Error` es un protocolo de Swift: los tipos que lo cumplen se pueden usar con `throw`.
/// - `LocalizedError` además nos deja escribir un mensaje legible (`errorDescription`)
///   que luego se muestra al usuario con `error.localizedDescription`.
enum ErrorAutenticacion: LocalizedError {
    case credencialesIncorrectas
    case tokenInvalido

    var errorDescription: String? {
        switch self {
        case .credencialesIncorrectas: "Correo o contraseña incorrectos."
        case .tokenInvalido: "Tu sesión ya no es válida. Inicia sesión de nuevo."
        }
    }
}

// MARK: - AutenticacionManager

/// Simula un servidor de inicio de sesión (ejemplo "Login", día 8).
///
/// Capa MVVM: **Service** (un "Manager"). Hace dos cosas: recibe un correo y una contraseña
/// y devuelve una `Sesion`, y revisa un token guardado para devolver la `Sesion` a la que pertenece.
/// En ambos casos puede lanzar un error. No guarda estado ni toca la interfaz.
///
/// OJO: en una app real esto sería una petición de red (`URLSession`) a un servidor,
/// y la contraseña se compararía allá, nunca dentro de la app. Aquí usamos un usuario
/// fijo solo para practicar el flujo.
struct AutenticacionManager {
    // MARK: - Instancia compartida

    // `static let shared` crea UNA sola instancia que todos reutilizan.
    // `private init()` impide que alguien más cree otras con `AutenticacionManager()`.
    static let shared = AutenticacionManager()
    private init() {}

    // Credenciales de prueba (las mismas que muestra la pantalla).
    private let correoDemo = "alumno@unam.mx"
    private let contrasenaDemo = "swift2026"

    /// El usuario que "devolvería el servidor". Es una propiedad calculada:
    /// se arma cada vez que se lee, usando `correoDemo`.
    private var usuarioDemo: Usuario {
        Usuario(nombre: "Alumno UNAM", correo: correoDemo)
    }

    // MARK: - Acciones

    /// Intenta iniciar sesión. Tarda un segundo para simular la espera de la red.
    ///
    /// - `async` marca una función que puede esperar sin congelar la pantalla.
    ///   Se llama con `await`.
    /// - `throws` marca una función que puede fallar. Se llama con `try`.
    func iniciarSesion(correo: String, contrasena: String) async throws -> Sesion {
        // Pausa de 1 segundo. Mientras espera, la interfaz sigue respondiendo.
        try await Task.sleep(for: .seconds(1))

        // `trimmingCharacters` quita espacios al inicio y al final; `lowercased` pasa a minúsculas.
        let correoLimpio = correo.trimmingCharacters(in: .whitespaces).lowercased()

        // `guard` revisa una condición y, si NO se cumple, ejecuta el `else` y sale.
        guard correoLimpio == correoDemo, contrasena == contrasenaDemo else {
            throw ErrorAutenticacion.credencialesIncorrectas
        }

        // El token es un texto aleatorio. Un servidor real devolvería uno firmado.
        return Sesion(usuario: usuarioDemo, token: UUID().uuidString)
    }

    /// Revisa un token que la app guardó antes y devuelve la sesión a la que pertenece.
    /// Es lo que haría un servidor real al recibir el token: comprobar que sigue siendo válido.
    func restaurarSesion(token: String) async throws -> Sesion {
        // Pausa corta para simular la consulta al servidor.
        try await Task.sleep(for: .milliseconds(500))

        // `UUID(uuidString:)` devuelve nil si el texto no tiene forma de UUID.
        // Así simulamos un token inválido o alterado.
        guard UUID(uuidString: token) != nil else {
            throw ErrorAutenticacion.tokenInvalido
        }

        return Sesion(usuario: usuarioDemo, token: token)
    }
}
