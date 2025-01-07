# ElasticCollision2D

[![CI](https://github.com/terasakisatoshi/ElasticCollision2D.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/terasakisatoshi/ElasticCollision2D.jl/actions/workflows/CI.yml)

A Julia package for simulating and visualizing elastic collisions of multiple balls in 2D space.

This code was generated using the Composer feature in Cursor Editor, with Claude-3-5-Sonnet-20241022 as the underlying model.

## Latest Release (v0.1.1)

The latest version (v0.1.1) includes significant improvements to the physics simulation:
- Physically accurate elastic collision implementation
- Fixed collision handling for balls of different sizes
- Improved position correction using mass ratios
- Enhanced numerical stability

## Demo

Running the example script `examples/bouncing_ball.jl` generates an animation of 10 balls with random sizes and velocities colliding elastically within a bounded box:

```bash
$ julia --project=. examples/bouncing_ball.jl
Starting simulation...
Box created: BoundingBox(10.0, 8.0)
Created 10 balls
Creating animation...
Output file: bouncing_balls.mp4
Starting animation simulation...
Number of frames: 1000
Creating figure...
Recording animation to: bouncing_balls.mp4
Animation recording completed!
Animation completed!
Checking if file exists: true
```

### Demo Animation

[Download the demo animation](https://github.com/terasakisatoshi/ElasticCollision2D.jl/releases/download/v0.1.1/bouncing_balls.mp4)

You can also view it on the [releases page](https://github.com/terasakisatoshi/ElasticCollision2D.jl/releases/tag/v0.1.1).

The generated animation demonstrates:
- Random initialization of 10 balls with different sizes
- Physically accurate elastic collisions between balls
- Proper handling of collisions between balls of different sizes
- Wall collisions and reflections
- Perfect conservation of energy and momentum
- Mass-dependent collision response

## Features

- Physically accurate elastic collision simulation
- Precise collision detection and resolution for balls of any size
- Mass-based collision response with perfect energy conservation
- Smooth animation output using CairoMakie
- Configurable simulation parameters (time step, duration, etc.)
- Support for multiple balls with different sizes and masses

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
