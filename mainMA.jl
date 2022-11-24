"""
Main simulation of the lone parent model 

Run this script from shell as 
# julia mainMA.jl

from REPL execute it using 
> include("mainMA.jl")
"""

include("mainMAHelpers.jl")

const mainConfig = Light()    # no input files, logging or flags (REPL Exec.) 
# mainConfig = WithInputFiles()

const lpmExample = LPMUKDemography()    # remove deads
# lpmExample = LPMUKDemographyOpt()   # don't remove deads 

const simPars, pars = loadParameters(mainConfig) 

# Most significant simulation and model parameters 
# The following works only with Light() configuration
#   useful when executing from REPL
if mainConfig == Light() 
    simPars.seed = 0; seed!(simPars)
    simPars.verbose = false   
    simPars.checkassumption = false 
    simPars.sleeptime = 0 
    pars.poppars.initialPop = 500
end

const model = setupModel(pars)

const logfile = setupLogging(simPars,mainConfig)

const demoData = loadDemographyData(pars.datapars)

const ukDemography = MAModel(model,pars,demoData)

const lpmDemographySim = 
    ABMSimulationP{typeof(simPars)}(simPars,setupEnabled = false)
    
setup!(lpmDemographySim,lpmExample) 
 
# Execution 
@time run!(ukDemography,lpmDemographySim,lpmExample)

closeLogfile(logfile,mainConfig)
 
