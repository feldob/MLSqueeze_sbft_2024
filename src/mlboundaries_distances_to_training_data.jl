struct Dataset
    id
    td_id
    inputs
    output
end

datasets = [ Dataset("synth", "synth", [:x1, :x2], :class),
            Dataset("iris", "Iris", [:SepalLengthCm, :SepalWidthCm, :PetalLengthCm, :PetalWidthCm], :Species),
            Dataset("titanic", "titanic_pp", [:Pclass, :Age, :Sex, :Fare, :Parch, :SibSp], :Survived),
            Dataset("car", "car_evaluation_pp", [:buyingprice, :maintenancecost, :doors, :capacity, :luggageboot, :safety], :decision),
            Dataset("wine", "wine", [:Alcohol,:Malicacid,:Ash,:Acl,:Mg,:Phenols,:Flavanoids,:Nonflavanoidphenols,:Proanth,:Colorint,:Hue,:OD,:Proline], :Wine),
            Dataset("heart", "heart", [:age, :sex, :cp, :trestbps, :chol, :fbs, :restecg, :thalach, :exang, :oldpeak, :slope,:ca, :thal], :target),
            Dataset("adult", "adult_pp", [:age,:fnlwgt,:educationalnum,:gender,:capitalgain,:capitalloss,:hoursperweek], :income)
]

right(inputs) = map(i -> "n_$(i)", string.(inputs))

function nearest_neighbor_distance(bc::DataFrameRow, td)
    d = map(d -> evaluate(Euclidean(), bc, d), eachrow(td))
    return sort(d)[2]
end

function extract_distances_for(df_bcs, dataset, file="$DATA_DIR/$(dataset.td_id).csv")
    df = CSV.read(file, DataFrame)

    og_dict = Dict()
    output_grouped = groupby(df, dataset.output)
    foreach(gf -> og_dict[first(gf)[dataset.output]] = gf, output_grouped)

    output = string(dataset.output)
    n_output = "n_$(dataset.output)"
    output_grouped_bcs = groupby(df_bcs, [output, n_output])

    df = DataFrame(bc_id = Int[], output = eltype(dataset.output)[], distance = Float64[])

    df_inputs = delete!(similar(first(output_grouped_bcs))[:, dataset.inputs], :)
    bc_id = 0
    for bcs_group in output_grouped_bcs
        output_v = first(bcs_group)[output]
        td_left = og_dict[output_v][:, dataset.inputs] |> Matrix
        bcs_left = bcs_group[!, dataset.inputs]
        # for each left bc, calculate the distance to all td entries in left
        distances_left = map(bc -> nearest_neighbor_distance(bc, td_left), eachrow(bcs_left))
        foreach(p -> push!(df, (p[1]+bc_id, output_v, p[2])) , enumerate(distances_left))
        foreach(r -> push!(df_inputs, Tuple(r)) , eachrow(bcs_left))
        
        n_output_v = first(bcs_group)[n_output]
        td_right = og_dict[n_output_v][:, dataset.inputs] |> Matrix
        bcs_right = bcs_group[!, right(dataset.inputs)]
        # for each right bc, calculate the distance to all td entries in right
        distances_right = map(bc -> nearest_neighbor_distance(bc, td_right), eachrow(bcs_right))
        foreach(p -> push!(df, (p[1]+bc_id, n_output_v, p[2])) , enumerate(distances_right))
        foreach(r -> push!(df_inputs, Tuple(r)) , eachrow(bcs_right))

        bc_id += nrow(bcs_group)
    end

    foreach(n -> df[:,n] = df_inputs[:,n], names(df_inputs))
    return df
end

function bcs(dataset, n_cand, method)
    file = "$EXP_DIR/$(dataset.id)_bcs_$(method)_$(n_cand)_pp.csv"
    if !isfile(file)
        file = "$EXP_DIR/$(dataset.id)_bcs_$(method)_$(n_cand).csv"
    end

    return CSV.read(file, DataFrame)
end

function cal_distances(file::String, dataset, datasetfile="$DATA_DIR/$(dataset.td_id).csv")
    df_bcs = CSV.read(file, DataFrame)
    return extract_distances_for(df_bcs, dataset, datasetfile)
end

function cal_distances(dataset, n_cand, method)
    df_bcs = bcs(dataset, n_cand, method)
    return extract_distances_for(df_bcs, dataset)
end

function extract_all_distances_for_experiments()
    mkpath("$EXP_DIR/bc_td_distances")
    for ds in datasets
        println(ds.id)
        for n_cand in [10, 20]
            df_d = cal_distances(ds, n_cand, "div")
            df_r = cal_distances(ds, n_cand, "random")

            CSV.write("$EXP_DIR/bc_td_distances/$(ds.id)_bcs_div_$(n_cand).csv", df_d)
            CSV.write("$EXP_DIR/bc_td_distances/$(ds.id)_bcs_random_$(n_cand).csv", df_r)
        end
    end
end

extract_all_distances_for_experiments()

df_dist_r = cal_distances("$EXP_DIR/synth_model_points_random_20.csv", datasets[1])
df_dist_d = cal_distances("$EXP_DIR/synth_model_points_div_20.csv", datasets[1])

CSV.write("$RES_DIR/synth_model_distances_random_20.csv", df_dist_r)
CSV.write("$RES_DIR/synth_model_distances_div_20.csv", df_dist_d)