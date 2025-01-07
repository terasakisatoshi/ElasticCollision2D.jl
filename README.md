# ElasticCollision2D

[![CI](https://github.com/terasakisatoshi/ElasticCollision2D.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/terasakisatoshi/ElasticCollision2D.jl/actions/workflows/CI.yml)

A Julia package for simulating and visualizing elastic collisions of multiple balls in 2D space.

This code was generated using the Composer feature in Cursor Editor, with Claude-3-5-Sonnet-20241022 as the underlying model.

## Features

- Accurate physics simulation of elastic collisions between balls
- Collision detection and resolution with walls and other balls
- Verlet integration for stable numerical simulation
- Smooth animation output using CairoMakie
- Configurable simulation parameters (time step, duration, etc.)
- Support for multiple balls with different sizes

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/terasakisatoshi/ElasticCollision2D.jl")
```

## Quick Start

```julia
using ElasticCollision2D

# Create a boundary box
box = BoundingBox(10.0, 8.0)

# Create some balls
balls = [
    BouncingBall([1.0, 1.0], [2.0, 1.5], 0.3),  # position, velocity, radius
    BouncingBall([5.0, 4.0], [-1.0, -1.0], 0.4)
]

# Run simulation and save animation
save_animation(balls, box, 10.0, 0.01, "collision.mp4")
```

## Example

Check out the example script in `examples/bouncing_ball.jl` which demonstrates:
- Random ball generation with different sizes
- Collision handling between multiple balls
- Wall collision handling
- Animation generation with proper scaling

## Physics Details

The simulation implements:
- Perfect elastic collisions (energy and momentum conservation)
- Verlet integration for accurate motion
- Position correction to prevent ball overlap
- Wall collisions with proper reflection

## Dependencies

- Julia 1.11 or higher
- CairoMakie
- FFMPEG
- LinearAlgebra

## License

MIT License
