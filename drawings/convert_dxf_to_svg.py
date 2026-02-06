#!/usr/bin/env python3
"""Convert DXF files to SVG for web display."""

import ezdxf
from ezdxf.addons.drawing import RenderContext, Frontend
from ezdxf.addons.drawing.matplotlib import MatplotlibBackend
import matplotlib.pyplot as plt

def dxf_to_svg(dxf_path, svg_path, title=""):
    """Convert a DXF file to SVG."""
    doc = ezdxf.readfile(dxf_path)
    msp = doc.modelspace()

    # Set up the figure
    fig = plt.figure(figsize=(12, 12))
    ax = fig.add_axes([0.05, 0.05, 0.9, 0.9])

    # Create the backend and render
    ctx = RenderContext(doc)
    out = MatplotlibBackend(ax)
    Frontend(ctx, out).draw_layout(msp)

    # Style the plot
    ax.set_aspect('equal')
    ax.set_facecolor('white')
    ax.grid(True, linestyle='--', alpha=0.3)
    if title:
        ax.set_title(title, fontsize=14, fontweight='bold')

    # Save as SVG
    fig.savefig(svg_path, format='svg', bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close(fig)
    print(f"  Created: {svg_path}")

if __name__ == '__main__':
    print("Converting DXF files to SVG...")

    dxf_to_svg('flex_spline.dxf', 'flex_spline_dxf.svg',
               'Flex Spline - 200 External Teeth')

    dxf_to_svg('circular_spline.dxf', 'circular_spline_dxf.svg',
               'Circular Spline - 202 Internal Teeth')

    dxf_to_svg('wave_generator.dxf', 'wave_generator_dxf.svg',
               'Wave Generator - Elliptical Cam')

    print("\nDone! SVG files ready for web display.")
