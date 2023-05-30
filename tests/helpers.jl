using Test
using MultiAgents: MAVERSION, init_majl, verify_agentsjl
using SocioEconomics: SEVERSION
using SocioEconomics.XAgents
using SocioEconomics.ParamTypes
using SocioEconomics.Specification.Declare

import SocioEconomics.ParamTypes: load_parameters
import SocioEconomics.API.ModelFunc: all_people, alive_people

@assert MAVERSION == v"0.5.1"
init_majl()  # reset agents id counter

@assert SEVERSION == v"0.4.5"  # Unit testing

function load_parameters()
    simPars = SimulationPars()
    ParamTypes.seed!(simPars)
    dataPars = DataPars()
    pars = DemographyPars()
    simPars, dataPars, pars
end

# flat model structure
mutable struct DemographyModel
    const towns :: Vector{PersonTown}
    const houses :: Vector{PersonHouse}
    const pop :: Vector{Person}
    const parameters :: DemographyPars
    const data :: DemographyData
    time :: Rational{Int}
end

all_people(model::DemographyModel) = model.pop
alive_people(model::DemographyModel) = [ person for person in model.pop if alive(person) ]

function declare_demographic_model(ips = 1000)
    simPars, dataPars, pars = load_parameters()
    pars.poppars.initialPop = ips

    data = load_demography_data(dataPars)

    towns =  Vector{PersonTown}(declare_inhabited_towns(pars))
    houses = Vector{PersonHouse}()
    pop = declare_pyramid_population(pars)
    model = DemographyModel(towns, houses, pop, pars, data, simPars.starttime)

    return model
end
