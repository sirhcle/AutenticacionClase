import LocalAuthentication

// MARK: - TipoBiometria

/// El tipo de biometría que tiene el dispositivo.
///
/// Capa MVVM: **Model** (vive junto al Manager porque solo él lo produce).
enum TipoBiometria {
    case faceID
    case touchID
    case opticID
    case ninguna

    /// Nombre para mostrar en pantalla.
    var nombre: String {
        switch self {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        case .ninguna: "Sin biometría disponible"
        }
    }

    /// Ícono SF Symbol de cada tipo.
    var icono: String {
        switch self {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        case .ninguna: "lock.slash"
        }
    }
}

// MARK: - Errores

/// Los resultados que no son un "sí". Cada uno pide un mensaje distinto para el usuario.
enum ErrorBiometria: LocalizedError {
    case noDisponible(String)
    case cancelada
    case fallida
    case otro(String)

    var errorDescription: String? {
        switch self {
        case .noDisponible(let motivo): "No se puede usar la biometría: \(motivo)"
        case .cancelada: "Cancelaste la verificación."
        case .fallida: "No te reconocimos. Intenta de nuevo."
        case .otro(let motivo): motivo
        }
    }
}

// MARK: - BiometriaManager

/// Pide al sistema que verifique a la persona con Face ID o Touch ID (ejemplo "Biometría", día 8).
///
/// Capa MVVM: **Service** (un "Manager"). Es como un portero: la app le pregunta
/// "¿es el dueño del teléfono?" y recibe solo sí o no. Nunca ve la cara ni la huella.
///
/// Requiere la clave `NSFaceIDUsageDescription` en el target → Info.
struct BiometriaManager {
    // MARK: - Instancia compartida

    static let shared = BiometriaManager()
    private init() {}

    // MARK: - Acciones

    /// Qué biometría tiene disponible el dispositivo ahora mismo.
    func tipoDisponible() -> TipoBiometria {
        let contexto = LAContext()
        // `NSError?` es una caja opcional donde el sistema deja el motivo si algo falla.
        var error: NSError?

        // Hay que llamar a `canEvaluatePolicy` ANTES de leer `biometryType`;
        // si no, el sistema todavía no lo ha calculado y devuelve "ninguna".
        guard contexto.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .ninguna
        }

        switch contexto.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .ninguna
        }
    }

    /// Pide la verificación. Si todo sale bien, termina sin lanzar error;
    /// si no, lanza un `ErrorBiometria` que indica qué pasó.
    ///
    /// - `motivo` es el texto que ve el usuario en el aviso del sistema.
    func autenticar(motivo: String) async throws {
        let contexto = LAContext()
        var errorPrevio: NSError?

        // Primero confirmamos que se pueda: puede faltar Face ID o no estar configurado.
        guard contexto.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorPrevio) else {
            throw ErrorBiometria.noDisponible(errorPrevio?.localizedDescription ?? "motivo desconocido")
        }

        do {
            // Aquí el sistema muestra su aviso y espera. Devuelve true si la persona fue reconocida.
            let reconocido = try await contexto.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: motivo
            )
            if !reconocido { throw ErrorBiometria.fallida }
        } catch let error as LAError {
            // Traducimos los errores del sistema a los nuestros, que son más fáciles de mostrar.
            switch error.code {
            case .userCancel, .appCancel, .systemCancel: throw ErrorBiometria.cancelada
            case .authenticationFailed: throw ErrorBiometria.fallida
            default: throw ErrorBiometria.otro(error.localizedDescription)
            }
        }
    }
}
