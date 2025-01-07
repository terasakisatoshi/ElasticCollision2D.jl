using Test
using ElasticCollision2D
using LinearAlgebra

@testset "ElasticCollision2D.jl" begin
    @testset "BouncingBall Construction" begin
        # Test basic construction
        ball = BouncingBall([0.0, 0.0], [1.0, 1.0], 0.5)
        @test ball.position == [0.0, 0.0]
        @test ball.velocity == [1.0, 1.0]
        @test ball.radius == 0.5
        @test ball.mass ≈ π * 0.5^2  # mass = π * r^2 (density = 1)

        # Test with different values
        ball2 = BouncingBall([1.0, 2.0], [-1.0, 0.5], 0.3)
        @test ball2.position == [1.0, 2.0]
        @test ball2.velocity == [-1.0, 0.5]
        @test ball2.radius == 0.3
        @test ball2.mass ≈ π * 0.3^2
    end

    @testset "BoundingBox Construction" begin
        box = BoundingBox(10.0, 8.0)
        @test box.width == 10.0
        @test box.height == 8.0
    end

    @testset "Collision Detection" begin
        # Test overlapping balls
        ball1 = BouncingBall([0.0, 0.0], [0.0, 0.0], 0.5)
        ball2 = BouncingBall([0.8, 0.0], [0.0, 0.0], 0.5)
        is_colliding, overlap, normal = check_collision(ball1, ball2)
        @test is_colliding == true
        @test overlap ≈ 0.2 atol=1e-6
        @test normal ≈ [1.0, 0.0] atol=1e-6

        # Test non-overlapping balls
        ball3 = BouncingBall([2.0, 0.0], [0.0, 0.0], 0.5)
        is_colliding, overlap, normal = check_collision(ball1, ball3)
        @test is_colliding == false
        @test overlap == 0.0
        @test normal == [0.0, 0.0]
    end

    @testset "Collision Resolution" begin
        # Test head-on collision
        ball1 = BouncingBall([0.0, 0.0], [1.0, 0.0], 0.5)
        ball2 = BouncingBall([0.9, 0.0], [-1.0, 0.0], 0.5)
        initial_momentum = ball1.mass * ball1.velocity + ball2.mass * ball2.velocity
        initial_energy = 0.5 * ball1.mass * dot(ball1.velocity, ball1.velocity) +
                        0.5 * ball2.mass * dot(ball2.velocity, ball2.velocity)

        resolve_collision!(ball1, ball2)

        # Check momentum conservation
        final_momentum = ball1.mass * ball1.velocity + ball2.mass * ball2.velocity
        @test initial_momentum ≈ final_momentum atol=1e-10

        # Check energy conservation
        final_energy = 0.5 * ball1.mass * dot(ball1.velocity, ball1.velocity) +
                      0.5 * ball2.mass * dot(ball2.velocity, ball2.velocity)
        @test initial_energy ≈ final_energy atol=1e-10
    end

    @testset "Wall Collision" begin
        box = BoundingBox(10.0, 8.0)
        balls = [BouncingBall([0.3, 0.3], [-1.0, -1.0], 0.5)]

        # Test left wall collision
        update!(balls, box, 0.1)
        @test balls[1].position[1] ≥ balls[1].radius
        @test balls[1].velocity[1] > 0  # Should bounce back with positive x velocity

        # Test bottom wall collision
        @test balls[1].position[2] ≥ balls[1].radius
        @test balls[1].velocity[2] > 0  # Should bounce back with positive y velocity
    end

    @testset "Collision Time Prediction" begin
        # Test approaching balls
        ball1 = BouncingBall([0.0, 0.0], [1.0, 0.0], 0.5)
        ball2 = BouncingBall([2.0, 0.0], [-1.0, 0.0], 0.5)
        time = predict_collision_time(ball1, ball2)
        @test time ≈ 0.5 atol=1e-6

        # Test parallel moving balls
        ball3 = BouncingBall([0.0, 0.0], [1.0, 0.0], 0.5)
        ball4 = BouncingBall([0.0, 2.0], [1.0, 0.0], 0.5)
        @test predict_collision_time(ball3, ball4) == Inf

        # Test balls moving away
        ball5 = BouncingBall([0.0, 0.0], [-1.0, 0.0], 0.5)
        ball6 = BouncingBall([2.0, 0.0], [1.0, 0.0], 0.5)
        @test predict_collision_time(ball5, ball6) == Inf
    end
end