using Pkg

function initpackages(doit::Bool)
    if !doit
        return
    end
    Pkg.add("StatsPlots")
    Pkg.add("DataFrames")
    Pkg.add("CSV")
    Pkg.add("DecisionTree")
    Pkg.add("Statistics")
    Pkg.add("Distances")
    Pkg.add(url="https://github.com/feldob/MLSqueeze")
end

# Load packages, first time
initpackages(true)

using CSV, DataFrames, DecisionTree, MLSqueeze

DATA_DIR = "datasets"
EXP_DIR = "experiments"
RES_DIR = "stats"

mkpath(EXP_DIR)
mkpath(RES_DIR)

# preprocess the input spaces into continuous spaces
include("create_numeric_csvs.jl")

# create BC's for all datasets with 10 and 20 candidates, for search with and without diversity in search
include("mlboundaries_all.jl")

# postprocess results
include("mlboundaries_pp.jl")

# distance table in LaTeX
# + normalized distance plots 
include("mlboundaries_distances_models.jl")

# create boundaries for diagrams for the synth problem
include("mlboundaries_synth_model.jl")

# extract distances for sync dataset for 20 candidates
include("mlboundaries_distances_to_training_data.jl")
