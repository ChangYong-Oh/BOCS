function [data1, data2, data3] = summary_individual_files(model_name, dir_name)
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
		group_evals = [group_evals, evals];
	end
end
