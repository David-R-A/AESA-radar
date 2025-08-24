import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

def generate_phased_array_image(num_elements=8, steer_angle_deg=30, wave_color='blue', dpi=300):
    """
    Genera una imagen estática del patrón de radiación de una antena en fase.
    
    Parámetros:
    - num_elements: número de elementos de la antena
    - steer_angle_deg: ángulo de dirección del haz en grados (-90 a 90)
    - wave_color: color de las ondas ('blue' o 'red')
    - dpi: resolución de la imagen en puntos por pulgada
    
    Retorna:
    - La figura generada
    """
    # Parámetros iniciales
    wavelength = 1.0
    element_spacing = 0.5 * wavelength
    k = 2 * np.pi / wavelength  # Número de onda
    
    # Configuración de la figura con mayor tamaño
    fig = plt.figure(figsize=(12, 10), dpi=dpi)  # Mayor resolución
    # plt.suptitle(f'Simulación de Antenas en Fase', fontsize=16)
    
    # Área principal para la simulación
    ax_main = plt.gca()
    ax_main.set_xlim(-10, 10)
    ax_main.set_ylim(0, 15)  # Solo la mitad superior
    ax_main.set_aspect('equal')
    #ax_main.set_xlabel('X (longitudes de onda)', fontsize=12)
    #ax_main.set_ylabel('Y (longitudes de onda)', fontsize=12)
    #ax_main.set_title(f'Dirección: {steer_angle_deg}°, Elementos: {num_elements}', fontsize=14)
    #ax_main.grid(True, linestyle='--', alpha=0.7)
    
    # Funciones de cálculo
    def get_element_positions(num_elements, element_spacing):
        """Calcula las posiciones de los elementos de la antena."""
        positions = np.zeros((num_elements, 2))
        
        # Colocar elementos a lo largo del eje X
        for i in range(num_elements):
            x = (i - (num_elements - 1) / 2) * element_spacing
            positions[i] = [x, 0]
        
        return positions
    
    def calculate_phase_shifts(positions, k, steer_angle_deg):
        """Calcula los cambios de fase para la dirección deseada."""
        steer_angle_rad = np.deg2rad(steer_angle_deg)
        
        # Calcular desfase progresivo para cada elemento
        # El signo positivo aquí corrige la dirección del haz
        phase_shifts = k * positions[:, 0] * np.sin(steer_angle_rad)
        
        return phase_shifts
    
    def calculate_field(X, Y, positions, phase_shifts, k):
        """Calcula el campo electromagnético en cada punto del espacio."""
        # Distancia de cada punto a cada elemento
        field = np.zeros_like(X)
        
        # Tiempo fijo para generar una imagen estática
        t = 0
        
        for i in range(len(positions)):
            dx = X - positions[i, 0]
            dy = Y - positions[i, 1]
            r = np.sqrt(dx**2 + dy**2)
            
            # Campo de cada elemento: onda esférica con fase ajustada
            # Amplitud disminuye con 1/r
            amplitude = 1.0 / np.maximum(r, 0.1)  # Evitar división por cero
            phase = k * r + phase_shifts[i]
            
            # Sumar contribución de este elemento
            field += amplitude * np.cos(phase - 2*np.pi*t)
            
        return field
    
    # Crear matriz de puntos para calcular el campo con mayor resolución
    x = np.linspace(-10, 10, 500)  # Aumentado de 200 a 500 puntos
    y = np.linspace(0, 15, 375)    # Aumentado de 100 a 250 puntos
    X, Y = np.meshgrid(x, y)
    
    # Calcular posiciones de los elementos y fases
    wavelength = 1.0
    element_spacing = 0.5 * wavelength
    k = 2 * np.pi / wavelength
    
    positions = get_element_positions(num_elements, element_spacing)
    phase_shifts = calculate_phase_shifts(positions, k, steer_angle_deg)
    
    # Calcular el campo electromagnético
    Z = calculate_field(X, Y, positions, phase_shifts, k)
    
    # Colores basados en el valor del campo
    cmap = plt.cm.Blues if wave_color == 'blue' else plt.cm.Reds
    
    # Crear visualización del campo con interpolación mejorada
    field_plot = ax_main.pcolormesh(
        X, Y, Z, 
        cmap=cmap,
        shading='gouraud',  # Cambiado de 'auto' a 'gouraud' para suavizar
        norm=colors.Normalize(-1, 1)
    )
    
    # Dibujar los elementos de la antena
    ax_main.scatter(
        positions[:, 0], positions[:, 1],
        color='black', s=80, marker='o',  # Aumentado el tamaño
        label='Elementos de la antena'
    )
    
    # Dibujar la línea de dirección correcta
    angle_rad = np.deg2rad(steer_angle_deg)
    dx = 8 * np.sin(angle_rad)
    dy = 8 * np.cos(angle_rad)
    if dy < 0:  # Asegurarse de que la flecha apunte hacia arriba
        dx = -dx
        dy = -dy
    #ax_main.arrow(0, 0, dx, dy, 
    #    color='red', width=0.1, head_width=0.4, head_length=0.6,
    #    length_includes_head=True, label='Dirección del haz'
    #)

    x1 = np.array([0, dx*3])
    y1 = np.array([0, dy*3])

    ax_main.plot(x1, y1, color = 'black', ls = '--')
    ax_main.axis('off')
    
    # Agregar barra de color con mayor nivel de detalle
    #cbar = plt.colorbar(field_plot, ax=ax_main, pad=0.02, fraction=0.046)
    #cbar.set_label('Amplitud del campo', fontsize=12)
    #cbar.ax.tick_params(labelsize=10)
    
    # Agregar leyenda con mejor posicionamiento
    #ax_main.legend(loc='upper right', fontsize=12)
    
    # Mejorar la apariencia general
    plt.tight_layout(rect=[0, 0, 1, 0.96])  # Ajustar disposición
    
    return fig

# Función para generar la imagen
def crear_imagen_antena_fase(num_elementos=8, angulo_direccion=30, color_onda='blue', dpi=300, guardar=False, nombre_archivo="simulacion_antena_fase.png"):
    """
    Crea una imagen de la simulación de antena en fase con los parámetros especificados.
    
    Parámetros:
    - num_elementos: número de elementos de la antena
    - angulo_direccion: ángulo de dirección del haz en grados (-90 a 90)
    - color_onda: 'blue' o 'red'
    - dpi: resolución de la imagen en puntos por pulgada
    - guardar: si es True, guarda la imagen en un archivo
    - nombre_archivo: nombre del archivo donde guardar la imagen
    """
    fig = generate_phased_array_image(num_elementos, angulo_direccion, color_onda, dpi)
    
    if guardar:
        # Guardar imagen con alta resolución
        plt.savefig(nombre_archivo, dpi=dpi, bbox_inches='tight')
        print(f"Imagen guardada como {nombre_archivo}")
    
    plt.show()
    return fig

# Ejemplo de uso
if __name__ == "__main__":
    # Cambiar estos valores según se desee
    NUM_ELEMENTOS = 8
    ANGULO = 30  # grados
    COLOR = 'blue'  # 'blue' o 'red'
    DPI = 300  # Resolución de la imagen (puntos por pulgada)
    
    # Generar y guardar imagen de alta resolución
    crear_imagen_antena_fase(
        num_elementos=NUM_ELEMENTOS,
        angulo_direccion=ANGULO, 
        color_onda=COLOR,
        dpi=DPI,
        guardar=True,  # Guardar la imagen en un archivo
        nombre_archivo=f"antena_fase_{NUM_ELEMENTOS}elem_{ANGULO}grados_{COLOR}.png"
    )