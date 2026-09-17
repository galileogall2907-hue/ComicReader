import SwiftUI

struct LibraryItemCard: View {
    let item: LibraryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cover
            
            // Sección de textos e información
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.author ?? item.format.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // Nueva barra de progreso estilizada fuera de la portada
                if item.progress > 0 {
                    ProgressView(value: item.progress)
                        .tint(item.progress >= 1.0 ? .green : .accentColor) // Verde si está completado
                        .scaleEffect(x: 1, y: 0.6, anchor: .center) // Línea delgada y elegante
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var cover: some View {
        ZStack(alignment: .topTrailing) { // Cambiado a la esquina superior derecha
            
            // Fondo / Portada del Cómic
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            item.format.tint.opacity(0.95),
                            item.format.tint.opacity(0.65)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Icono del formato integrado sutilmente en el centro
            Image(systemName: item.format.symbolName)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Pequeño indicador (Badge) del formato en la esquina superior
            Text(item.format.displayName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(8)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        // Borde interior fino para simular el canto de las hojas o el doblez de la portada (Efecto Editorial)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        // Sombra con degradado más suave y estática de diseño moderno (Sombra difusa)
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
    }

    private var accessibilityLabel: String {
        var parts = [item.title, item.format.displayName]
        if let author = item.author {
            parts.insert(author, at: 1)
        }
        if item.progress > 0 {
            parts.append("\(Int(item.progress * 100)) por ciento completado")
        }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    LibraryItemCard(item: .samples[0])
        .frame(width: 160)
        .padding()
        .background(Color(.systemGroupedBackground))
}
