using ElasticNetworks, Test, ForwardDiff

cube_net = cubic_network(10, 10)
actin_net = load_network("../data/threshold0x001_conc0.5_maxrl3_epsilon0x05_17500.jld2")

function grad_autodiff(net)
    net_info = net_info_primitive(net)
    basis, ini_points, egs, rls, iis, youngs = net_info
    energy(points) = elastic_energy(basis, points, egs, rls, iis, youngs)
    return ForwardDiff.gradient(energy, ini_points)
end

@testset "energy gradient" begin
    ad_gradient = grad_autodiff(actin_net)
    ana_gradient = energy_gradient(actin_net)
    @test all(abs.(ad_gradient - ana_gradient) .< 1e-6)
end

function hessian_autodiff(net)
    net_info = net_info_primitive(net)
    basis, ini_points, egs, rls, iis, youngs = net_info
    energy(points) = elastic_energy(basis, points, egs, rls, iis, youngs)
    return ForwardDiff.hessian(energy, ini_points)
end

@testset "energy hessian" begin
    ad_hessian = hessian_autodiff(actin_net)
    ana_hessian = energy_hessian(actin_net)
    @test all(abs.(ad_hessian - ana_hessian) .< 1e-6)
    ad_hessian = hessian_autodiff(cube_net)
    ana_hessian = energy_hessian(cube_net)
    @test all(abs.(ad_hessian - ana_hessian) .< 1e-6)
end

@testset "moduli" begin
    B, G = moduli(cube_net)[1:2]
    @test (B ≈ 1/3 && G ≈ 1/5)
end