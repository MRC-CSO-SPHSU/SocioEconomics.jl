using EnumX

export WorkBlock
export set_empty_job_schedule!, set_full_weekly_time!

export WorkStatus

# better (scoped) enums from package EnumX
@enumx WorkStatus child teenager student worker retired unemployed

# TODO some of this should probably be moved to Care
mutable struct WorkBlock
    "work status"
    status :: WorkStatus.T
    outOfTownStudent :: Bool
    newEntrant :: Bool
    initialIncome :: Float64
    finalIncome :: Float64
    wage :: Float64
    income :: Float64
    "income for full work schedule"
    potentialIncome :: Float64
    "periods worked so far in current job"
    jobTenure :: Int
    "7x24 schedule of actual working hours"
    schedule :: Matrix{Int}
    "potential total working hours per week"
    workingHours :: Int         
    "free time slots"
    weeklyTime :: Matrix{Int}
    "sum of realised working hours"
    availableWorkingHours :: Int
    "lifetime work"
    workingPeriods :: Int
    pension :: Float64
end

WorkBlock() = WorkBlock(WorkStatus.child, false, true, 0, 0, 0, 0, 0, 0, zeros(Int, 7, 24),
                        0, zeros(Int, 7, 24), 0, 0, 0)

function set_empty_job_schedule!(work)
    work.schedule = zeros(Int, 7, 24)
end

function set_full_weekly_time!(work)
    work.weeklyTime = ones(Int, 7, 24)
end
