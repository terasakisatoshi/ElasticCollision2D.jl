using ElasticCollision2D
using CairoMakie
using FFMPEG
using Random
using LinearAlgebra

function create_random_balls(n::Int, box::BoundingBox)
    Random.seed!(42)  # Fix random seed for reproducibility

    balls = BouncingBall[]
    for i in 1:n
        # Random radius (range: 0.2-0.6)
        radius = 0.2 + rand() * 0.4

        # Random initial position (ensure balls fit within boundary)
        max_attempts = 100  # Maximum attempts for position determination
        position = nothing

        for attempt in 1:max_attempts
            x = radius + rand() * (box.width - 2radius)
            y = radius + rand() * (box.height - 2radius)
            candidate_position = [x, y]

            # Check overlap with other balls
            overlapping = false
            for existing_ball in balls
                diff = candidate_position - existing_ball.position
                min_distance = radius + existing_ball.radius
                if norm(diff) < min_distance
                    overlapping = true
                    break
                end
            end

            if !overlapping
                position = candidate_position
                break
            end
        end

        # Skip if suitable position not found
        if position === nothing
            println("Warning: Could not place ball $i after $max_attempts attempts")
            continue
        end

        # Random initial velocity
        speed = 2.0 + rand() * 2.0  # range: 2.0-4.0
        angle = rand() * 2π
        velocity = [speed * cos(angle), speed * sin(angle)]

        push!(balls, BouncingBall(position, velocity, radius))
    end

    return balls
end

function main()
    try
        println("Starting simulation...")

        # Set up simulation environment
        box = BoundingBox(10.0, 8.0)  # boundary width and height
        println("Box created: ", box)

        # Generate 10 balls
        balls = create_random_balls(10, box)
        println("Created $(length(balls)) balls")

        println("Creating animation...")

        # Create and save animation
        # 10 seconds simulation with 0.01 second time step (100 FPS)
        filename = "bouncing_balls.mp4"
        println("Output file: ", abspath(filename))

        fig = save_animation(balls, box, 10.0, 0.01, filename)

        println("Animation completed!")
        println("Checking if file exists: ", isfile(filename))
    catch e
        println("Error occurred: ", e)
        println("Error type: ", typeof(e))
        println("Backtrace: ")
        for (exc, bt) in Base.catch_stack()
            showerror(stdout, exc, bt)
            println()
        end
    end
end

main()