using Distributions: Normal, LogNormal

export socialTransition!, selectSocialTransition

using XAgents 


function selectSocialTransition(p, pars)
    alive(p) && hasBirthday(p) && 
    age(p) == workingAge(p, pars) &&
    status(p) == WorkStatus.student
end


# class sensitive versions
# TODO? 
# * move to separate, optional module
# * replace with non-class version here
initialIncomeLevel(person, pars) = pars.incomeInitialLevels[classRank(person)+1]

workingAge(person, pars) = pars.workingAge[classRank(person)+1]

function incomeDist(person, pars)
    # TODO make parameters
    if classRank(person) == 0
        LogNormal(2.5, 0.25)
    elseif classRank(person) == 1
        LogNormal(2.8, 0.3)
    elseif classRank(person) == 2
        LogNormal(3.2, 0.35)
    elseif classRank(person) == 3
        LogNormal(3.7, 0.4)
    elseif classRank(person) == 4
        LogNormal(4.5, 0.5)
    else
        error("unknown class rank!")
    end
end

# TODO dummy, replace
# or, possibly remove altogether and calibrate model 
# properly instead
socialClassShares(model, class) = 0.2

function studyClassFactor(person, model, pars)
    if classRank(person) == 0 
        return socialClassShares(model, 0) > 0.2 ?  1/0.9 : 0.85
    end

    if classRank(person) == 1 && socialClassShares(model, 1) > 0.35
        return 1/0.8
    end

    if classRank(person) == 2 && socialClassShares(model, 2) > 0.25
        return 1/0.85
    end

    1.0
end

doneStudying(person, pars) = classRank(person) >= 4

# TODO
function addToWorkforce!(person, model)
end

# move newly adult agents into study or work
function socialTransition!(person, time, model, pars)
    probStudy = doneStudying(person, pars)  ?  
        0.0 : startStudyProb(person, model, pars)

    if rand() < probStudy
        startStudying!(person, pars)
    else
        startWorking!(person, pars)
        addToWorkforce!(person, model)
    end
end


# probability to start studying instead of working
function startStudyProb(person, model, pars)
    if father(person) == nothing && mother(person) == nothing
        return 0.0
    end
    
    if provider(person) == nothing
        return 0.0
    end

                                # renamed from python but same calculation
    perCapitaDisposableIncome = householdIncomePerCapita(person)

    if perCapitaDisposableIncome <= 0
        return 0.0
    end

    forgoneSalary = initialIncomeLevel(person, pars) * 
        pars.weeklyHours[careNeedLevel(person)+1]
    relCost = forgoneSalary / perCapitaDisposableIncome
    incomeEffect = (pars.constantIncomeParam+1) / 
        (exp(pars.eduWageSensitivity * relCost) + pars.constantIncomeParam)

    # TODO factor out class
    targetEL = father(person) != nothing ? 
        max(classRank(father(person)), classRank(mother(person))) :
        classRank(mother(person))
    dE = targetEL - classRank(person)
    expEdu = exp(pars.eduRankSensitivity * dE)
    educationEffect = expEdu / (expEdu + pars.constantEduParam)

    careEffect = 1/exp(pars.careEducationParam * (socialWork(person) + childWork(person)))

    pStudy = incomeEffect * educationEffect * careEffect

    pStudy *= studyClassFactor(person, model, pars)

    return max(0.0, pStudy)
end

function startStudying!(person, pars)
    addClassRank!(person, 1) 
end

# TODO here for now, maybe not the best place?
function resetWork!(person, pars)
    status!(person, WorkStatus.unemployed)
    newEntrant!(person, true)
    workingHours!(person, 0)
    income!(person, 0)
    jobTenure!(person, 0)
    # TODO
    # monthHired
    # jobShift
    setEmptyJobSchedule!(person)
    outOfTownStudent!(person, true)
end

function startWorking!(person, pars)

    resetWork!(person, pars)

    dKi = rand(Normal(0, pars.wageVar))
    initialIncome!(person, initialIncomeLevel(person, pars) * exp(dKi))

    dist = incomeDist(person, pars)

    finalIncome!(person, rand(dist))

    # updates provider as well
    setAsSelfproviding!(person)

# commented in original:
#        if person.classRank < 4:
#            dKf = np.random.normal(dKi, self.p['wageVar'])
#            person.finalIncome = self.p['incomeFinalLevels'][person.classRank]*math.exp(dKf)
#        else:
#            sigma = float(self.p['incomeFinalLevels'][person.classRank])/5.0
            # person.finalIncome = np.random.lognormal(self.p['incomeFinalLevels'][person.classRank], sigma)
            
#        person.wage = person.initialIncome
#        person.income = person.wage*self.p['weeklyHours'][int(person.careNeedLevel)]
#        person.potentialIncome = person.income
end

