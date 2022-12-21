module Initialize

using Distributions: Normal
using Random:  shuffle 
using ....XAgents 
using ....ParamTypes
import ....API.Connection: AbsInitPort, AbsInitProcess, 
                            initialConnect!, init! 


export InitHousesInTownsPort, InitCouplesToHousesPort
export AbsInitProcess, InitClassesProcess, InitWorkProcess
export initialConnect!, init!


struct InitHousesInTownsPort <: AbsInitPort end
struct InitCouplesToHousesPort <: AbsInitPort end  

struct InitClassesProcess <: AbsInitProcess end 
struct InitWorkProcess <: AbsInitProcess end 

"initialize houses in a given set of towns"
function initializeHousesInTowns_(towns, pars) 

    houses = PersonHouse[] 

    for town in towns
        if town.density > 0

            adjustedDensity = town.density * pars.mapDensityModifier
         
            for hx in 1:pars.townGridDimension  
                for hy in 1:pars.townGridDimension 
        
                    if(rand() < adjustedDensity)
                        house = PersonHouse(town,(hx,hy))
                        push!(houses,house)
                    end
        
                end # for hy 
            end # for hx 
  
        end # if town.density 
    end # for town 
    
    return houses  
end  # function initializeHousesInTwons 


function initialConnect!(houses, towns, pars,::InitHousesInTownsPort)
    newHouses = initializeHousesInTowns_(towns, mapParameters(pars))
    append!(houses, newHouses)
end

initialConnect!(houses::Vector{PersonHouse},
                towns::Vector{Town},
                pars) = 
    initialConnect!(houses,towns,pars,InitHousesInTownsPort())


"Randomly assign a population of couples to non-inhebted set of houses"
function assignCouplesToHouses_!(population::Vector{Person}, houses::Vector{PersonHouse})
    women = [ person for person in population if isFemale(person) ]

    randomhouses = shuffle(houses)

    for woman in women
        house = pop!(randomhouses) 
        
        moveToHouse!(woman, house) 
        if !isSingle(woman)
            moveToHouse!(partner(woman), house)
        end

        for child in dependents(woman)
            moveToHouse!(child, house)
        end
    end # for person     

    for person in population
        if person.pos == UNDEFINED_HOUSE
            @assert isMale(person)
            @assert length(randomhouses) >= 1
            moveToHouse!(person, pop!(randomhouses))
        end
    end
end  # function assignCouplesToHouses 

function initialConnect!(pop, houses, pars, ::InitCouplesToHousesPort)
    assignCouplesToHouses_!(pop, houses)
    nothing 
end

initialConnect!(pop::Vector{Person}, 
                houses::Vector{PersonHouse}, 
                pars) = 
    initialConnect!(pop,houses,pars,InitCouplesToHousesPort())

function initClass_!(person, pars)
    p = rand()
    class = findfirst(x->p<x, pars.cumProbClasses)-1
    classRank!(person, class)
    nothing
end

function init!(pop,pars,::InitClassesProcess) 
    for person in pop 
        initClass_!(person,populationParameters(pars))
    end 
end 


function initWork_!(person, pars)
    class = classRank(person)+1
    workingTime = 0
    for i in age(person):pars.workingAge[class]
        workingTime *= pars.workDiscountingTime
        workingTime += 1
    end

    dKi = rand(Normal(0, pars.wageVar))
    initialWage = pars.incomeInitialLevels[class] * exp(dKi)
    dKf = rand(Normal(dKi, pars.wageVar))
    finalWage = pars.incomeFinalLevels[class] * exp(dKf)

    initialIncome!(person, initialWage)
    finalIncome!(person, finalWage)

    c = log(initialWage/finalWage)
    wage!(person, finalWage * exp(c * exp(-pars.incomeGrowthRate[class]*workingTime)))
    income!(person, wage(person) * pars.weeklyHours[class])
    potentialIncome!(person, income(person))
    jobTenure!(person, rand(1:50))
#    workExperience = workingTime

    nothing
end


function init!(pop,pars,::InitWorkProcess) 
    for person in pop 
        initWork_!(person,workParameters(pars))
    end 
end 


end # module Initalize 
