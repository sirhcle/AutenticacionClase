import SwiftUI

/// Estado de la pantalla "Keychain: guardar el token" (ejemplo del día 8).
///
/// Capa MVVM: **ViewModel**. Guarda el texto que escribe el usuario y el token que ya está
/// en el Keychain. Para guardar, leer y borrar usa `KeychainManager`.
@MainActor
@Observable
final class KeychainViewModel {

    // MARK: - Estado

    /// Texto que el usuario escribe para guardar (la vista lo conecta con `@Bindable`).
    var tokenNuevo = ""

    /// Token que hay ahora en el Keychain; nil si no hay ninguno.
    private(set) var tokenGuardado: String?

    /// Mensaje breve sobre lo último que pasó (guardado, borrado, error...).
    private(set) var mensaje: String?

    /// Nombre bajo el que guardamos el token dentro del Keychain.
    private let cuenta = "tokenDemo"

    // MARK: - Ciclo de vida

    /// Al crear el ViewModel leemos el Keychain, así el token sigue ahí
    /// aunque hayas cerrado y vuelto a abrir la app.
    init() {
        leer()
    }

    // MARK: - Propiedades calculadas

    /// El token con casi todo oculto, para no mostrar el secreto completo en pantalla.
    /// `suffix(4)` toma los últimos 4 caracteres.
    var tokenOculto: String? {
        guard let token = tokenGuardado else { return nil }
        return "••••••••" + token.suffix(4)
    }

    // MARK: - Acciones

    /// Guarda `tokenNuevo` en el Keychain.
    func guardar() {
        guard !tokenNuevo.isEmpty else {
            mensaje = "Escribe un token antes de guardar."
            return
        }
        do {
            try KeychainManager.shared.guardar(tokenNuevo, cuenta: cuenta)
            tokenNuevo = ""
            mensaje = "Token guardado en el Keychain."
            leer()
        } catch {
            mensaje = error.localizedDescription
        }
    }

    /// Lee el token del Keychain y actualiza `tokenGuardado`.
    func leer() {
        do {
            tokenGuardado = try KeychainManager.shared.leer(cuenta: cuenta)
        } catch {
            mensaje = error.localizedDescription
        }
    }

    /// Borra el token del Keychain.
    func borrar() {
        do {
            try KeychainManager.shared.borrar(cuenta: cuenta)
            tokenGuardado = nil
            mensaje = "Token borrado."
        } catch {
            mensaje = error.localizedDescription
        }
    }
}
