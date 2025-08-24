import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, RadioButtons, Button
from matplotlib import animation
import matplotlib.colors as colors

class PhasedArraySimulation:
    def __init__(self):
        # Initial parameters
        self.num_elements = 8
        self.wavelength = 1.0
        self.element_spacing = 0.5 * self.wavelength
        self.steer_angle_deg = 0
        self.wave_color = 'blue'
        self.k = 2 * np.pi / self.wavelength  # Wave number
        
        # Sweep parameters
        self.sweep_active = False
        self.sweep_positions = [-60, -30, 0, 30, 60]  # 5 positions in degrees
        self.sweep_current_index = 0
        self.sweep_time_per_position = 2  # 4 seconds each position (20 seconds total)
        self.sweep_counter = 0
        
        # Figure setup
        self.fig = plt.figure(figsize=(10, 8))
        self.fig.canvas.manager.set_window_title('Phased Array Antenna Simulation')
        
        # Main simulation area
        self.ax_main = self.fig.add_axes([0.1, 0.25, 0.8, 0.65])
        self.ax_main.set_xlim(-10, 10)
        self.ax_main.set_ylim(0, 10)  # Modified: only show upper half (y ≥ 0)
        self.ax_main.set_aspect('equal')
        self.ax_main.set_xlabel('X (wavelengths)')
        self.ax_main.set_ylabel('Y (wavelengths)')
        self.ax_main.set_title('Phased Array Radiation Pattern')
        self.ax_main.grid(True, linestyle='--', alpha=0.7)
        
        # Direction slider
        self.ax_angle = self.fig.add_axes([0.15, 0.1, 0.65, 0.03])
        self.angle_slider = Slider(
            self.ax_angle, 'Direction (degrees)', -90, 90,
            valinit=self.steer_angle_deg, valstep=1
        )
        self.angle_slider.on_changed(self.update_angle)
        
        # Number of elements slider
        self.ax_elements = self.fig.add_axes([0.15, 0.05, 0.65, 0.03])
        self.elements_slider = Slider(
            self.ax_elements, 'Elements', 2, 16,
            valinit=self.num_elements, valstep=1
        )
        self.elements_slider.on_changed(self.update_elements)
        
        # Color radio buttons
        self.ax_radio = self.fig.add_axes([0.025, 0.05, 0.08, 0.1])
        self.radio_buttons = RadioButtons(
            self.ax_radio, ('Blue', 'Red'),
            active=0
        )
        self.radio_buttons.on_clicked(self.update_color)
        
        # Add sweep button
        self.ax_sweep = self.fig.add_axes([0.87, 0.05, 0.1, 0.03])
        self.sweep_button = Button(self.ax_sweep, 'Sweep')
        self.sweep_button.on_clicked(self.toggle_sweep)
        
        # Initialize animation
        self.setup_plot()
        self.ani = animation.FuncAnimation(
            self.fig, self.animate, interval=50, 
            frames=100, blit=True
        )
    
    def get_element_positions(self):
        """Calculates the positions of the antenna elements."""
        positions = np.zeros((self.num_elements, 2))
        
        # Place elements along X axis
        for i in range(self.num_elements):
            x = (i - (self.num_elements - 1) / 2) * self.element_spacing
            positions[i] = [x, 0]
        
        return positions
    
    def calculate_phase_shifts(self):
        """Calculates the phase shifts for the desired direction."""
        steer_angle_rad = np.deg2rad(self.steer_angle_deg)
        positions = self.get_element_positions()
        
        # Calculate progressive phase shift for each element
        phase_shifts = -self.k * positions[:, 0] * np.sin(steer_angle_rad)
        
        return phase_shifts
    
    def calculate_field(self, X, Y, t):
        """Calculates the electromagnetic field at each point in space."""
        positions = self.get_element_positions()
        phase_shifts = self.calculate_phase_shifts()
        
        # Distance from each point to each element
        field = np.zeros_like(X)
        
        for i in range(self.num_elements):
            dx = X - positions[i, 0]
            dy = Y - positions[i, 1]
            r = np.sqrt(dx**2 + dy**2)
            
            # Field of each element: spherical wave with adjusted phase
            # Amplitude decreases with 1/r
            amplitude = 1.0 / np.maximum(r, 0.1)  # Avoid division by zero
            phase = self.k * r + phase_shifts[i]
            
            # Add contribution of this element
            field += amplitude * np.cos(phase - 2*np.pi*t)
            
        return field
    
    def setup_plot(self):
        """Sets up the initial visual elements."""
        # Create grid of points to calculate the field
        x = np.linspace(-10, 10, 200)
        y = np.linspace(0, 10, 100)  # Modified: only points in y ≥ 0
        self.X, self.Y = np.meshgrid(x, y)
        
        # Initial field
        Z = self.calculate_field(self.X, self.Y, 0)
        
        # Colors based on field value
        cmap = plt.cm.Blues if self.wave_color == 'blue' else plt.cm.Reds
        
        # Create field visualization
        self.field_plot = self.ax_main.pcolormesh(
            self.X, self.Y, Z, 
            cmap=cmap,
            shading='auto',
            norm=colors.Normalize(-1, 1)
        )
        
        # Draw antenna elements
        positions = self.get_element_positions()
        self.antenna_elements = self.ax_main.scatter(
            positions[:, 0], positions[:, 1],
            color='black', s=50, marker='o'
        )
        
        # Draw direction line (inverted from original)
        angle_rad = np.deg2rad(self.steer_angle_deg)
        dx = -8 * np.sin(angle_rad)  # Changed sign to invert direction
        dy = 8 * np.cos(angle_rad)
        self.direction_line, = self.ax_main.plot(
            [0, dx], [0, dy], 
            'k--', linewidth=2
        )
        
        # Text to display information
        self.info_text = self.ax_main.text(
            -9.5, 9,
            f"Direction: {self.steer_angle_deg}°\nElements: {self.num_elements}",
            bbox=dict(facecolor='white', alpha=0.7)
        )
        
        return self.field_plot, self.antenna_elements, self.direction_line, self.info_text
    
    def animate(self, frame):
        """Updates the animation for each frame."""
        t = frame / 20.0  # Normalized time
        
        # Update sweep if active
        if self.sweep_active:
            self.sweep_counter += 1
            frames_per_position = self.sweep_time_per_position * 20  # 20 frames per second
            
            if self.sweep_counter >= frames_per_position:
                self.sweep_counter = 0
                self.sweep_current_index = (self.sweep_current_index + 1) % len(self.sweep_positions)
                self.steer_angle_deg = self.sweep_positions[self.sweep_current_index]
                
                # Update slider to match
                self.angle_slider.set_val(self.steer_angle_deg)
                
                # Update direction line
                angle_rad = np.deg2rad(self.steer_angle_deg)
                dx = -8 * np.sin(angle_rad)
                dy = 8 * np.cos(angle_rad)
                self.direction_line.set_data([0, dx], [0, dy])
                
                # Update info text
                self.info_text.set_text(
                    f"Direction: {self.steer_angle_deg}°\nElements: {self.num_elements}"
                )
        
        # Update the field
        Z = self.calculate_field(self.X, self.Y, t)
        self.field_plot.set_array(Z.ravel())
        
        # Update antenna element positions
        positions = self.get_element_positions()
        self.antenna_elements.set_offsets(positions)
        
        return self.field_plot, self.antenna_elements, self.direction_line, self.info_text
    
    def update_angle(self, val):
        """Updates the beam direction."""
        self.steer_angle_deg = val
        
        # Update direction line (inverted from original)
        angle_rad = np.deg2rad(self.steer_angle_deg)
        dx = -8 * np.sin(angle_rad)  # Changed sign to invert direction
        dy = 8 * np.cos(angle_rad)
        self.direction_line.set_data([0, dx], [0, dy])
        
        # Update info text
        self.info_text.set_text(
            f"Direction: {self.steer_angle_deg}°\nElements: {self.num_elements}"
        )
    
    def update_elements(self, val):
        """Updates the number of elements."""
        self.num_elements = int(val)
        
        # Update info text
        self.info_text.set_text(
            f"Direction: {self.steer_angle_deg}°\nElements: {self.num_elements}"
        )
    
    def update_color(self, label):
        """Updates the wave color."""
        if label == 'Blue':
            self.wave_color = 'blue'
            self.field_plot.set_cmap(plt.cm.Blues)
        else:
            self.wave_color = 'red'
            self.field_plot.set_cmap(plt.cm.Reds)
    
    def toggle_sweep(self, event):
        """Toggle the automatic sweep mode."""
        self.sweep_active = not self.sweep_active
        self.sweep_counter = 0
        self.sweep_current_index = 0
        
        if self.sweep_active:
            self.steer_angle_deg = self.sweep_positions[0]
            self.angle_slider.set_val(self.steer_angle_deg)
            self.sweep_button.label.set_text('Stop')
        else:
            self.sweep_button.label.set_text('Sweep')
    
    def show(self):
        """Shows the simulation."""
        plt.show()

# Run the simulation
if __name__ == "__main__":
    simulation = PhasedArraySimulation()
    simulation.show()