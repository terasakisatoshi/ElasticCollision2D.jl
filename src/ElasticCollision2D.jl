module ElasticCollision2D

using LinearAlgebra
using CairoMakie
using FFMPEG

export BouncingBall, BoundingBox
export update!, draw_scene, animate_simulation, save_animation
export check_collision, resolve_collision!, predict_collision_time

"""
    BouncingBall(position, velocity, radius, mass)

A structure representing a ball in 2D plane.
"""
mutable struct BouncingBall
    position::Vector{Float64}  # [x, y]
    velocity::Vector{Float64}  # [vx, vy]
    radius::Float64
    mass::Float64             # mass (automatically calculated from radius)
end

# Constructor: automatically calculate mass from radius
function BouncingBall(position::Vector{Float64}, velocity::Vector{Float64}, radius::Float64)
    mass = π * radius^2  # assuming density = 1
    BouncingBall(position, velocity, radius, mass)
end

"""
    BoundingBox(width, height)

A structure representing a rectangular boundary.
"""
struct BoundingBox
    width::Float64
    height::Float64
end

"""
    predict_collision_time(ball1::BouncingBall, ball2::BouncingBall)

Predict the collision time between two balls.
"""
function predict_collision_time(ball1::BouncingBall, ball2::BouncingBall)
    Δr = ball1.position - ball2.position
    Δv = ball1.velocity - ball2.velocity
    r_sum = ball1.radius + ball2.radius

    a = dot(Δv, Δv)
    b = 2 * dot(Δr, Δv)
    c = dot(Δr, Δr) - r_sum^2

    discriminant = b^2 - 4a*c
    if discriminant < 0 || a ≈ 0
        return Inf
    end

    t1 = (-b - sqrt(discriminant)) / (2a)
    t2 = (-b + sqrt(discriminant)) / (2a)

    if t1 > 0
        return t1
    elseif t2 > 0
        return t2
    else
        return Inf
    end
end

"""
    check_collision(ball1::BouncingBall, ball2::BouncingBall)

Detect collision between two balls and return collision information.
"""
function check_collision(ball1::BouncingBall, ball2::BouncingBall)
    diff = ball2.position - ball1.position
    distance = norm(diff)
    min_distance = ball1.radius + ball2.radius

    # Collision detection with stricter numerical error consideration
    collision_tolerance = min_distance * 1e-8  # smaller threshold for better accuracy
    if distance < min_distance + collision_tolerance
        normal_unit = if distance > 1e-10
            diff / distance
        else
            [1.0, 0.0]
        end
        overlap = min_distance - distance
        return (true, overlap, normal_unit)
    end
    return (false, 0.0, zeros(2))
end

"""
    resolve_collision!(ball1::BouncingBall, ball2::BouncingBall)

Handle elastic collision between two balls.
"""
function resolve_collision!(ball1::BouncingBall, ball2::BouncingBall)
    is_colliding, overlap, normal_unit = check_collision(ball1, ball2)

    if !is_colliding
        return
    end

    # Position correction with stronger separation
    total_mass = ball1.mass + ball2.mass
    shift1 = (ball2.mass / total_mass) * overlap * 1.1  # 10% extra correction
    shift2 = (ball1.mass / total_mass) * overlap * 1.1

    ball1.position .+= shift1 * normal_unit
    ball2.position .-= shift2 * normal_unit

    # Velocity update with improved precision
    relative_velocity = ball1.velocity - ball2.velocity
    normal_velocity = dot(relative_velocity, normal_unit)

    if normal_velocity < 0
        # Collision with momentum conservation and perfect elasticity
        restitution = 1.0
        j = -(1 + restitution) * normal_velocity
        j_impulse1 = (j * ball2.mass / total_mass) * normal_unit
        j_impulse2 = (j * ball1.mass / total_mass) * normal_unit

        # Apply velocity changes with improved precision
        ball1.velocity .= ball1.velocity .+ j_impulse1
        ball2.velocity .= ball2.velocity .- j_impulse2
    end
end

"""
    update!(balls::Vector{BouncingBall}, box::BoundingBox, dt::Float64)

Update positions and velocities of all balls and handle collisions.
"""
function update!(balls::Vector{BouncingBall}, box::BoundingBox, dt::Float64)
    substeps = 400  # doubled substeps for better accuracy
    dt_sub = dt / substeps

    for _ in 1:substeps
        # Verlet integration with improved accuracy
        for ball in balls
            # Store old position for Verlet integration
            old_position = copy(ball.position)

            # Full position update
            ball.position .+= ball.velocity * dt_sub

            # Apply wall constraints immediately
            if ball.position[1] - ball.radius < 0
                ball.position[1] = ball.radius
                ball.velocity[1] = abs(ball.velocity[1])
            elseif ball.position[1] + ball.radius > box.width
                ball.position[1] = box.width - ball.radius
                ball.velocity[1] = -abs(ball.velocity[1])
            end

            if ball.position[2] - ball.radius < 0
                ball.position[2] = ball.radius
                ball.velocity[2] = abs(ball.velocity[2])
            elseif ball.position[2] + ball.radius > box.height
                ball.position[2] = box.height - ball.radius
                ball.velocity[2] = -abs(ball.velocity[2])
            end
        end

        # Multiple iterations of collision resolution for better accuracy
        for _ in 1:20  # doubled iterations
            for i in 1:length(balls)
                for j in (i+1):length(balls)
                    resolve_collision!(balls[i], balls[j])
                end
            end
        end
    end
end

"""
    draw_scene(balls::Vector{BouncingBall}, box::BoundingBox)

Return current scene state as a string (for debugging).
"""
function draw_scene(balls::Vector{BouncingBall}, box::BoundingBox)
    for (i, ball) in enumerate(balls)
        println("Ball $i position: ", ball.position)
        println("Ball $i velocity: ", ball.velocity)
        println("Ball $i radius: ", ball.radius)
        println("Ball $i mass: ", ball.mass)
    end
end

"""
    animate_simulation(balls::Vector{BouncingBall}, box::BoundingBox, duration::Float64, dt::Float64, filename::String)

Create animation of multiple balls' motion.
duration: simulation time (seconds)
dt: time step (seconds)
filename: output file name
"""
function animate_simulation(balls::Vector{BouncingBall}, box::BoundingBox, duration::Float64, dt::Float64, filename::String)
    println("Starting animation simulation...")

    # Calculate number of frames
    nframes = Int(ceil(duration / dt))
    println("Number of frames: ", nframes)

    # Array to store position data
    positions = [Vector{Vector{Float64}}(undef, nframes) for _ in 1:length(balls)]

    # Run simulation and store position data
    balls_copy = [BouncingBall(copy(ball.position), copy(ball.velocity), ball.radius) for ball in balls]
    for i in 1:nframes
        for (j, ball) in enumerate(balls_copy)
            positions[j][i] = copy(ball.position)
        end
        update!(balls_copy, box, dt)
    end

    println("Creating figure...")
    # Create animation
    fig = Figure(size=(800, 640))  # use size instead of resolution
    ax = Axis(fig[1, 1],
              aspect = box.width/box.height,
              xlabel = "x",
              ylabel = "y",
              title = "Bouncing Balls Simulation")

    # Set display range with margin
    margin = 0.5  # 0.5 units margin
    limits!(ax, -margin, box.width + margin, -margin, box.height + margin)

    # Draw boundary
    lines!(ax, [0, box.width, box.width, 0, 0], [0, 0, box.height, box.height, 0],
           color = :black, linewidth = 2)

    # Adjust ball drawing scale
    # Convert physical units (meters) to screen pixels
    pixels_per_meter = 800 / 10  # pixels per meter

    colors = [:blue, :red, :green, :orange, :purple, :cyan, :magenta, :yellow, :brown, :pink]
    ball_plots = [scatter!(ax, [ball.position[1]], [ball.position[2]],
                          color = colors[mod1(i, length(colors))],
                          markersize = ball.radius * pixels_per_meter * 2,  # diameter in pixels
                          marker = :circle) for (i, ball) in enumerate(balls)]

    println("Recording animation to: ", abspath(filename))
    # Create animation
    frames = 1:nframes
    record(fig, filename, frames; framerate = Int(1/dt)) do frame
        for (j, ball_plot) in enumerate(ball_plots)
            ball_plot[1] = [positions[j][frame][1]]
            ball_plot[2] = [positions[j][frame][2]]
        end
    end

    println("Animation recording completed!")
    return fig
end

"""
    save_animation(balls::Vector{BouncingBall}, box::BoundingBox, duration::Float64, dt::Float64, filename::String)

Run simulation and save animation as an MP4 file.
"""
function save_animation(balls::Vector{BouncingBall}, box::BoundingBox, duration::Float64, dt::Float64, filename::String="bouncing_balls.mp4")
    fig = animate_simulation(balls, box, duration, dt, filename)
    return fig
end

end # module ElasticCollision2D
