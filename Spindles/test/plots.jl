using RecipesBase, Plots  # need to also load Plots.jl to trigger loading the extension

@testset "Plots" begin

    @testset "Errors" begin
        # need to apply full recipe, not the single-argument shorthand since 
        # that one does not check the dimension
        @test try
            RecipesBase.apply_recipe(Dict{Symbol, Any}(), cube(3), Int[])
            false
        catch
            true
        end

        @test try
            RecipesBase.apply_recipe(Dict{Symbol, Any}(), cube(2), [1])
            false
        catch
            true
        end
    end
    
    @testset "Mark up edges" begin
        # deformed square
        p = Polytope([[-1, -1], [1, -1], [-5//4, 1], [5//4, 1]])

        recipe_data = RecipesBase.apply_recipe(
            Dict{Symbol, Any}(:markup_edges => ([3,1], [4,2])),
            p, Int[]
        )
        
        arrow_data = [
            data for data in recipe_data 
            if haskey(data.plotattributes, :seriestype) && data.plotattributes[:seriestype] == :arrow
        ]
        @test length(arrow_data) == 2

        # verify edge orientations
        for data in arrow_data
            x, y = data.args
            @test y == [-1, 1]
            @test abs.(x) == [1, 5//4]
        end
    end

    # TODO apply second recipe: #RecipesBase.apply_recipe(Dict{Symbol, Any}(), p)
    # TODO test: edge orientation is independent of vertex order in markup_edges
    # TODO test both use_coordinates on/off
    # TODO provide explicit ratio to enter specific code branch (:aspect_ratio => :auto)
end