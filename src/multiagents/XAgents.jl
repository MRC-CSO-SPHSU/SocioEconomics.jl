"""
Module for defining a supertype, AbstractAgent for all Agent types
    with additional ready-to-use agents to be used in (Multi-)ABMs models
"""
module XAgents

    using MultiAgents: AbstractAgent, AbstractXAgent, AbstractXSpace, getIDCOUNTER
    import MultiAgents: random_position, nearby_ids

    include("../agents/town.jl")
    include("../agents/house.jl")
    include("../agents/person.jl")
    include("../agents/world.jl")

end  # XAgents
