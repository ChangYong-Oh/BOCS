function [data1, data2, data3] = summary_individual_files(model_name, dir_name)
    my_naming = my_model_names();
    if ~any(strcmp(my_naming, model_name))
        sprintf(['----------------\n%s'], strjoin(my_naming, '\n'));
        error('Wrong model name')
    end
    
	filename_list = dir(dir_name);
	dir_name = filename_list(1).folder;
	group1 = {};
	group2 = {};
	group3 = {};
	for i=1:numel(filename_list)
		filename = filename_list(i).name;
		if numel(filename) < 5
			continue
        end
        if contains(filename, model_name)
            if strcmp(filename(end-6:end), '+00.mat')
                group1 = [group1, filename];
            elseif strcmp(filename(end-6:end), '-04.mat')
                group2 = [group2, filename];
            elseif strcmp(filename(end-6:end), '-02.mat')
                group3 = [group3, filename];
            end
        end
    end
    
	% 0.0, 1e-4, 1e-2
	data1 = collect_evals(group1, dir_name);
	data2 = collect_evals(group2, dir_name);
	data3 = collect_evals(group3, dir_name);
end

function [evaluations] = extract_evalautions(file_name, dir_name)
    load(strjoin([dir_name, file_name], '/'), 'model');
    evaluation_info = model;
    evaluations = evaluation_info.objVals;
end

function [group_evals] = collect_evals(file_names, dir_name)
	load(strjoin([dir_name, file_names(1)], '/'), 'input');
	n_eval = input.evalBudget;
    n_init = input.n_init;

	group_evals = zeros(n_eval, numel(file_names));
	for j=1:numel(file_names)
        evaluation = extract_evalautions(file_names(j), dir_name);
        min_evaluation = zeros(size(evaluation));
        for i=1:numel(evaluation)
           min_evaluation(i, 1) = min(evaluation(1:i, 1)); 
        end
        group_evals(1:end, j) = data_check(min_evaluation, n_eval, n_init, file_names{j});
	end
end

function [processed_eval] = data_check(evaluation, n_eval, n_init, file_name)
    type_full = {'ObliviousLocalSearch', 'RandomSearch', 'SimulatedAnnealing', 'SMAC'};
    type_bocs = {'BOCSorder2SA', 'BOCSorder2SDP', 'ExpectedImprovement', 'HorseShoeorder2SA', 'HorseShoeorder2SDP', 'MLEorder2SA', 'MLEorder2SDP'};
    if any(contains(file_name, type_full))
        processed_eval = evaluation(1:n_eval, 1);
    elseif any(contains(file_name, type_bocs))
        processed_eval = [zeros(n_init, 1); evaluation(1:(n_eval - n_init), 1)];
    elseif contains(file_name, 'SequentialMonteCarlo')
        n_eval_smc = numel(evaluation);
        processed_eval = [evaluation; evaluation(end, 1) * ones(n_eval - n_eval_smc, 1)];
    else
        error('Error')
    end
end