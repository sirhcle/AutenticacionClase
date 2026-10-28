import Foundation
import Security

// MARK: - Errores

/// Los problemas que puede dar el Keychain.
///
/// `OSStatus` es el número que devuelven las funciones del Keychain para decir
/// qué pasó (0 significa que todo salió bien).
enum ErrorKeychain: LocalizedError {
    case estado(OSStatus)
    case datosInvalidos
    
    var errorDescription: String? {
        switch self {
            
        case .estado(let codigo):
            "El Keychain respondió con el código \(codigo)"
        case .datosInvalidos:
            "El dato guardado no se pudo leer como texto"
        }
    }
}

// MARK: - KeychainManager

/// Guarda, lee y borra textos secretos (como un token) en el Keychain (ejemplo "Login", día 8).
///
/// Capa MVVM: **Service** (un "Manager"). El Keychain es la caja fuerte del sistema:
/// cifra lo que guardas y solo tu app puede abrirla. Sus funciones vienen de C y son
/// incómodas de usar, así que este Manager las envuelve en tres funciones sencillas.
struct KeychainManager {
    // MARK: - Instancia compartida

    static let shared = KeychainManager()
    private init() {}

    /// Nombre con el que agrupamos nuestros elementos en el Keychain.
    private let servicio = "mx.unam.AutenticacionApp"

    // MARK: - Acciones

    /// Guarda un texto bajo un nombre (`cuenta`). Si ya existía, lo reemplaza.
    func guardar(_ texto: String, cuenta: String) throws { }
    
    /// Lee el texto guardado. Devuelve `nil` si todavía no hay nada.
    func leer(cuenta: String) throws -> String? { "" }
    
    /// Borra el texto guardado. Si no había nada, tampoco se considera error.
    func borrar(cuenta: String) throws { }
    
    // MARK: - Apoyo

    /// Diccionario que identifica "nuestro" elemento: es la etiqueta de la caja dentro de la caja fuerte.
    /// Las tres funciones de arriba lo reutilizan para no repetirlo.
    /// `private` significa que solo se puede usar dentro de este archivo/tipo.
    private func consulta(cuenta: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword, // tipo: contraseña genérica
            kSecAttrService as String: servicio,           // de qué app/servicio es
            kSecAttrAccount as String: cuenta              // cuál de nuestros secretos
        ]
    }

}
