# app_tiktok

Aplicación Flutter para el parcial del tercer corte con autenticación Firebase
y un feed vertical de videos estilo TikTok.

## Funcionalidades

- Rutas protegidas con `go_router`: `/login`, `/registro` y `/feed`.
- Registro e inicio de sesión con correo y contraseña.
- Inicio de sesión con Google y Facebook.
- Validación con `Form` y `GlobalKey<FormState>`.
- Actualización del nombre visible después del registro.
- Feed con `PageView` vertical y reproducción con `video_player`.
- Cuatro videos verticales obtenidos de Pexels.
- Logout de Firebase y proveedores sociales.

## Configuración

Firebase está configurado mediante `flutterfire configure` para el proyecto
`app-parcial-7964a`.

Ejecuta:

```powershell
flutter pub get
flutter run
```

Para compilar la versión web:

```powershell
flutter build web
```

Firebase Authentication debe tener habilitados correo/contraseña, Google y
Facebook.

## Facebook OAuth

Agrega exactamente este URI válido en la configuración de inicio de sesión
OAuth de Facebook:

```text
https://app-parcial-7964a.firebaseapp.com/__/auth/handler
```

