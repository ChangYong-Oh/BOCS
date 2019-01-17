function [data1, data2, data3] = summary_group_files(model_name, dir_name)
    bocs_naming = bocs_model_names();
    if ~any(strcmp(bocs_naming, model_name))
        sprintf(['----------------\n%s'], strjoin(bocs_naming, '\n'));
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
		if strcmp(filename(end-4:end), '1.mat')
			group1 = [group1, filename];
		elseif strcmp(filename(end-4:end), '2.mat')
			group2 = [group2, filename];
		elseif strcmp(filename(end-4:end), '3.mat')
			group3 = [group3, filename];
		end
	end

	% 0.0, 1e-4, 1e-2
	data1 = collect_evals(group1, dir_name, model_name);
	data2 = collect_evals(group2, dir_name, model_name);
	data3 = collect_evals(group3, dir_name, model_name);
end

function [group_evals] = collect_evals(file_names, dir_name, model_name)
	load(strjoin([dir_name, file_names(1)], '/'), 'inputs_t');
	inputs = eval('inputs_t');
	n_eval = inputs.evalBudget;
    n_init = inputs.n_init;
    
	baseline_models = {'rnd', 'sa', 'bo', 'ols', 'smc', 'smac'};
	bocs_variants = {'bayes-sa', 'mle-sa', 'hs-sa', 'bayes-sdp', 'mle-sdp', 'hs-sdp'};

	model_type = model_name;
	model_subtype = '';
	if contains(model_name, '-')
		model_info = strsplit(model_name, '-');
		model_type = model_info{1};
		model_subtype = model_info{2};
	end
	model_name_cell = {model_type};

	group_evals = zeros(n_eval, 0);
	for j=1:numel(file_names)
		clear(model_name_cell{:})
		load(strjoin([dir_name, file_names(j)], '/'), model_type);
		model = eval(model_type);
		if any(strcmp(baseline_models, model_name))
		elseif any(strcmp(bocs_variants, model_name))
			if strcmp(model_subtype, 'sa')
				model = model.stSA2;
			elseif strcmp(model_subtype, 'sdp')
				model = model.sdp;
			else
				error('Wrong model subtype, check model_name')
			end				
		else
			error('Wrong model_name')
		end
		evals = model{1,1}.objVals;
        min_evals = zeros(size(evals));
        for i=1:numel(evals)
           min_evals(i, 1) = min(evals(1:i, 1)); 
        end
		group_evals = [group_evals, data_check(min_evals, n_eval, n_init, model_name)];
	end
end

function [processed_eval] = data_check(evaluation, n_eval, n_init, model_name)
    type_full = {'rnd', 'sa', 'bo', 'ols', 'smac'};
    type_bocs = {'bayes-sa', 'bayes-sdp', 'mle-sdp', 'mle-sa', 'hs-sdp', 'hs-sa'};
    if any(strcmp(model_name, type_full))
        processed_eval = evaluation(1:n_eval, 1);
    elseif any(strcmp(model_name, type_bocs))
        processed_eval = [zeros(n_init, 1); evaluation(1:(n_eval - n_init), 1)];
    elseif strcmp(model_name, 'smc')
        n_eval_smc = numel(evaluation);
        processed_eval = [evaluation; evaluation(end, 1) * ones(n_eval - n_eval_smc, 1)];
    else
        error('Error')
    end
end
