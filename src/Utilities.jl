"""
Diverse useful functions and types 
"""
module Utilities



# Functions
export createTimeStampedFolder, p_yearly2monthly, remove_unsorted! 
export removefirst!, date2yearsmonths, age2yearsmonths
export checkAssumptions!, ignoreAssumptions!, assumption, setDelay!, delay
export setVerbose!, unsetVerbose!, verbose, verbosePrint, delayedVerbose
export fuse


"remove first occurance of e in list"
function removefirst!(list, e)
    e ∉ list ? throw(ArgumentError("element $(e) not in $(list)")) : nothing 
    deleteat!(list, findfirst(x -> x == e, list)) 
    nothing 
end

"convert date in rational representation to (years, months) as tuple"
function date2yearsmonths(date::Rational{Int})
    date < 0 ? throw(ArgumentError("Negative age")) : nothing 
    12 % denominator(date) != 0 ? throw(ArgumentError("$(date) not in age format")) : nothing 
    years  = trunc(Int, numerator(date) / denominator(date)) 
    months = trunc(Int, numerator(date) % denominator(date) * 12 / denominator(date) )
    (years , months)
end 

age2yearsmonths(age) = date2yearsmonths(age)

p_yearly2monthly(p) = 1 - (1-p)^(1/12)

"Very efficiently remove element `index` from `list`. Does not preserve ordering of `list`."
function remove_unsorted!(list, index)
    list[index] = list[end]
    pop!(list)
end
 
mutable struct Debug
    checkAssumptions :: Bool
    verbose :: Bool
    sleeptime :: Float64
end

const debug = Debug(false, false, 0.0)

checkAssumptions!() = debug.checkAssumptions = true
ignoreAssumptions!() = debug.checkAssumptions = false

function assumption(check, args...)
    if debug.checkAssumptions
        check(args...)
    end
end

setDelay!(delay) = debug.sleeptime = delay
delay() = sleep(debug.sleeptime)

setVerbose!() = debug.verbose = true
unsetVerbose!() = debug.verbose = false

function verbose(output, args...)
    if debug.verbose
        output(args...)
    end
end

verbosePrint(args...) = verbose(println, args...)

function delayedVerbose(output, args...)
    if debug.verbose
        output(args...)
        delay()
    end
end


"obtain a named tuple type with the same field types and names as `struct_T`"
function tuple_type(struct_Ts...)
    names = [ name for struct_T in struct_Ts for name in fieldnames(struct_T) ]
    types = [ typ for struct_T in struct_Ts for typ in fieldtypes(struct_T) ]
    NamedTuple{Tuple(names), Tuple{types...}}
end

"construct a named tuple from `x`"
@generated function fuse(args...)
	# constructor call
	tuptyp = Expr(:quote, tuple_type(args...))
	
	# constructor arguments
	tup = Expr(:tuple)
    # iterate indices, @generated only catches 'args'
    for a in eachindex(args)
        for i in 1:fieldcount(args[a])
            push!(tup.args, :(getfield(args[$a], $i)) )
        end
    end
	
	# both put together
	:($tuptyp($tup))
end
end # module Utilities  
