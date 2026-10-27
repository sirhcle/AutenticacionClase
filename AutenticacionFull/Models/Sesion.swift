// MARK: - Usuario

/// Datos básicos de la persona que inició sesión.
///
/// Capa MVVM: **Model**. Solo guarda datos; no tiene lógica ni sabe nada de pantallas.
///
/// - `struct` es un tipo de dato propio que se copia al pasarlo de un lado a otro.
/// - Las propiedades son `let` (constantes): una vez creado el usuario, sus datos no cambian.
struct Usuario {
    let nombre: String
    let correo: String
}

// MARK: - Sesion

/// Una sesión abierta: quién es el usuario y el token que lo comprueba.
///
/// Capa MVVM: **Model**. Piensa en el token como una pulsera de concierto:
/// el servidor te la da una vez que te identificas y la app la muestra
/// en cada petición, sin volver a pedir la contraseña.
struct Sesion {
    let usuario: Usuario
    let token: String
}
