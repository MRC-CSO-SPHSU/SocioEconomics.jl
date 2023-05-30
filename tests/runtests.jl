"""
Run this script from shell as
# julia tests/runtests.jl

or within REPL

julia> include("tests/runtests.jl")
"""

using Test

@testset "Lone Parent Model Components Testing" begin

    include("./basictests.jl")
    include("./initializationtests.jl")



    #=
    @testset verbose=true "Person Modules" begin
        @testset verbose=true "BasicInfo Module" begin
            set_dead!(person1)
            @test !alive(person1)
        end
    end
    =#

    # stepping functions


    #=

    @testset verbose=true "BasicInfo Module" begin

        setDead!(person7)
        @test !alive(person7)

        agestepAlive!(person7)
        @test age(person7) < 25.01
        agestep!(person7)
        @test age(person7) > 25

    end

    @testset verbose=true "Kinship Module" begin

        set_as_parent_child!(person1,person6)
        @test person1 in person6.kinship.children
        @test father(person1) === person6

        set_as_parent_child!(person2,person4)
        @test mother(person2) === person4
        @test person2 in person4.kinship.children

        @test issingle(person1)
        set_as_partners!(person1,person4)
        @test !issingle(person4)
        @test partner(person1) === person4 && partner(person4) === person1

        @test_throws InvalidStateException set_as_partners!(person3,person4) # same gender

        @test_throws InvalidStateException set_as_parent_child!(person4,person5)  # unknown gender
        @test_throws ArgumentError set_as_parent_child!(person4,person1)          # ages incompatibe / well they are also partners
        @test_throws ArgumentError set_as_parent_child!(person2,person3)          # person 2 has a mother

        resolve_partnership!(person4,person1)
        @test issingle(person4)
        @test partner(person1) !== person4 && partner(person4) != person1
        @test_throws ArgumentError resolve_partnership!(person1,person4)

    end

    @testset verbose=true "Type Person" begin
        @test getHomeTown(person1) != nothing
        @test getHomeTownName(person1) == "Edinbrugh"

        set_as_partners!(person4,person6)
        @test !issingle(person6)
        @test !issingle(person4)

        person7 = Person(pos=person4.pos,gender=male,mother=person4,father=person6)
        @test father(person7) === person6
        @test mother(person7) === person4
        @test person7 ∈ children(person4)
        @test person7 ∈ children(person6)

        reset_partner!(person4)
        @test issingle(person6)
        @test issingle(person4)
    end

    @testset verbose=true "Type House" begin

        @test house1.id > 0
        @test house1.pos != nothing
        @test getHomeTown(house1) === edinbrugh
        @test location(house1) == (1,2)

        setHouse!(person1,house2) # person1.pos = house2
        @test getHomeTown(person1) === aberdeen
        @test person1 in house2.occupants

        setHouse!(person4,house2)
        @test getHomeTown(person4) === aberdeen

        person1.pos = house1
        @test_throws ArgumentError setHouse!(person1,house3)
        person1.pos = house2

        reset_house!(person4)
        @test undefined(person4.pos)

    end # House functionalities

    # detect_ambiguities(AgentTypes)

    #=
        testing ABMs TODO

        @test (pop = Population()) != nothing                           # Population means something
        @test household = Household() != nothing                        # a household instance is something

        @test_throws UndefVarError town = Town()                        # Town class is not yet implemented
        @test town = Town()                          skip=true
    =#

    # TODO testing ABMs once designed

    # TODO testing stepping functions once design is fixed

    @testset verbose=true "Utilities" begin
        simfolder = createTimeStampedFolder()
        @test !isempty(simfolder)
        @test isdir(simfolder)
    end

    @testset verbose=true "Lone Parent Model Simulation" begin

        #=

        To re-implement

        using  SocialSimulations: SocialSimulation


        simProperties = LoneParentsModel.loadSimulationParameters()
        lpmSimulation = SocialSimulation(LoneParentsModel.createPopulation,simProperties)

        @test LoneParentsModel.loadMetaParameters!(lpmSimulation) != nothing  skip=true
        @test LoneParentsModel.loadModelParameters!(lpmSimulation) != nothing skip=false
        @test LoneParentsModel.createShifts!(lpmSimulation) != nothing        skip=false
        =#

    end
    =#
end  # Lone Parent Model main components
