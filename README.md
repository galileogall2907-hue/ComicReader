# ComicReader

Lector nativo de cómics y libros para iOS e iPadOS. SwiftUI, código propio y solo frameworks de Apple.

Formatos previstos: `.cbz`, `.cbr`, `.pdf`, `.epub`, con documentos en iCloud Drive.

## Abrir el proyecto

Xcode no está instalado en esta máquina. En un Mac con Xcode 16+:

1. Abre `ComicReader.xcodeproj`.
2. Elige tu Team en Signing & Capabilities (hace falta cuenta de Apple Developer para iCloud).
3. Ejecuta en iPhone o iPad (simulador o dispositivo).

## Estructura

```
ComicReader/
  App/                 Punto de entrada, entitlements de iCloud
  Features/Library/    Pantalla principal: cuadrícula de la biblioteca
  Features/Reader/     Lector (siguiente paso)
  Models/              Tipos de archivo y ítems de biblioteca
  Services/            Acceso a iCloud Drive (esqueleto)
  Resources/           Assets e Info.plist (UTI, documentos)
```

## Licencias (arranque limpio)

Este repo no incluye librerías de terceros.

| Formato | Cómo se pensará | Nota |
| --- | --- | --- |
| PDF | PDFKit | Apple |
| EPUB | ZIP + XML con Foundation | Apple; EPUB es un zip de HTML/XML |
| CBZ | ZIP (imágenes) | Apple no tiene API ZIP de alto nivel; se puede implementar con Compression o, más adelante, una lib MIT |
| CBR | RAR | El formato RAR es propietario. **No** uses UnRAR si quieres App Store / licencia limpia. Mejor convertir a CBZ o dejar CBR para una fase posterior con un decodificador de licencia clara |

La app declara los UTI de `.cbz` y `.cbr` como tipos propios (no copiamos código de otros lectores).

## iCloud Drive

- Container: `iCloud.com.luismandujano.ComicReader`
- Capability: iCloud Documents (ver `ComicReader.entitlements`)

Hasta que firmes con un Team, iCloud no estará disponible; la UI de biblioteca ya funciona con datos de ejemplo.
