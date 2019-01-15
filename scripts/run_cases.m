    % Author: Ricardo Baptista and Matthias Poloczek
% Date:   June 2018
%
% See LICENSE.md for copyright information
%

function run_cases(inputs_all, lambda_vals, test_name, n_proc, algorithms)
% RUN_CASES: Functions runs the discrete optimization algorithms
% on all test cases specified in inputs_all with the lambda values
% prescribed in lambda_vals vector. The results are saved in the
% results/test_name folder.

% Find number of tests
n_test = length(inputs_all);

current_file_dir = strsplit(mfilename('fullpath'), '/');
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'algorithms'], '/')]));
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'tools'], '/')]));
save_filename_template = ['/' strjoin(current_file_dir(2:end-2), '/') '/results/' test_name '/%s_%d_%.2E.mat'];
implemented_algorithms = {'RandomSearch', 'SimulatedAnnealing', 'ExpectedImprovement', 'ObliviousLocalSearch', 'SequentialMonteCarlo', 'SMAC', 'BOCS-Bayes', 'BOCS-MLE', 'BOCS-HS'};
for i=1:numel(algorithms)
    if ~is_member(algorithms(i), implemented_algorithms)
        error('Check that the algorithms you want to run is implemented.')
    end    
end

%% Parallel Problem setup

% parpool(n_proc);
for t=1:n_test    

    % Set test inputs struct
    inputs_t = inputs_all{t};

    %% Run optimization
    for l=1:length(lambda_vals)
        
        sprintf(['On the test problem : %s\n\nTest Algorithms\n-%s'], test_name, strjoin(implemented_algorithms, '\n-'))
    
        % Define objective function with penalty term
        inputs_t.lambda = lambda_vals(l);
        penalty   = @(x) inputs_t.lambda*inputs_t.reg_term(x);
        objective = @(x) inputs_t.model(x) + penalty(x);

        fprintf('--------------------------------------------\n')
        fprintf('Test = %d/%d, Lambda = %f\n\n', t, n_test, lambda_vals(l));

        % Run different ML optimization algorithms
        
        if is_member('RandomSearch', implemented_algorithms)
            rnd = random_samp(objective, inputs_t); 
            fprintf('Random - Runtime: %f\n', sum(rnd.runTime));
            iSave(sprintf(save_filename_template, 'RandomSearch', t, inputs_t.lambda), rnd, inputs_t);
        end
        
        if is_member('SimulatedAnnealing', implemented_algorithms)
            sa = simulated_annealing(objective, inputs_t);
            fprintf('SA - Runtime = %f\n', sum(sa.runTime));
            iSave(sprintf(save_filename_template, 'SimulatedAnnealing', t, inputs_t.lambda), sa, inputs_t);
        end
        
        if is_member('ExpectedImprovement', implemented_algorithms)
            bo = bayes_opt(objective, inputs_t);
            fprintf('BO - Runtime = %f\n', sum(bo.runTime));
            iSave(sprintf(save_filename_template, 'ExpectedImprovement', t, inputs_t.lambda), bo, inputs_t);
        end
        
        if is_member('ObliviousLocalSearch', implemented_algorithms)
            ols = local_search(objective, inputs_t);
            fprintf('OLS - Runtime = %f\n', sum(ols.runTime));
            iSave(sprintf(save_filename_template, 'ObliviousLocalSearch', t, inputs_t.lambda), ols, inputs_t);
        end
        
        if is_member('SequentialMonteCarlo', implemented_algorithms)
            smc = binary_smc(objective, inputs_t);
            fprintf('SMC - Runtime = %f\n', sum(smc.runTime));
            iSave(sprintf(save_filename_template, 'SequentialMonteCarlo', t, inputs_t.lambda), smc, inputs_t);
        end
        
        if is_member('SMAC', implemented_algorithms)
            smac{l} = run_smac(objective, inputs_t);
            fprintf('SMAC - Runtime = %f\n', sum(smac.runTime));
            iSave(sprintf(save_filename_template, 'SMAC', t, inputs_t.lambda), smac, inputs_t);
        end
        
        % Run BOCS with Bayesian model
        inputs_t.estimator = 'bayes';
        
%         if is_member('BOCS-SA', implemented_algorithms)
%             bayes_SA1 = BOCS(inputs_t.model, penalty, inputs_t, 1, 'SA');
%             fprintf('Bayes.SA1 - Runtime = %f\n', sum(bayes_SA1.runTime));
%             iSave(sprintf(save_filename_template, 'BOCSorder1SA', t, inputs_t.lambda), bayes_SA1, inputs_t);
%         end

        if is_member('BOCS-SA', implemented_algorithms)
            bayes_SA2 = BOCS(inputs_t.model, penalty, inputs_t, 2, 'SA');
            fprintf('Bayes.SA2 - Runtime = %f\n', sum(bayes_SA2.runTime));
            iSave(sprintf(save_filename_template, 'BOCSorder2SA', t, inputs_t.lambda), bayes_SA2, inputs_t);
        end

%         if is_member('BOCS-SA', implemented_algorithms)
%             bayes_SA3 = BOCS(inputs_t.model, penalty, inputs_t, 3, 'SA');
%             fprintf('Bayes.SA3 - Runtime = %f\n', sum(bayes_SA3.runTime));
%             iSave(sprintf(save_filename_template, 'BOCSorder3SA', t, inputs_t.lambda), bayes_SA3, inputs_t);
%         end

        if is_member('BOCS-SA', implemented_algorithms)
            bayes_sdp = BOCS(inputs_t.model, penalty, inputs_t, 2, 'sdp');
            fprintf('Bayes.SDP - Runtime = %f\n', sum(bayes_sdp.runTime));
            iSave(sprintf(save_filename_template, 'BOCSorder2SDP', t, inputs_t.lambda), bayes_sdp, inputs_t);
        end

        % Run BOCS with MLE model
        inputs_t.estimator = 'mle';
        
%         if is_member('BOCS-MLE', implemented_algorithms)
%             mle_SA1 = BOCS(inputs_t.model, penalty, inputs_t, 1, 'SA');
%             fprintf('MLE.SA1 - Runtime = %f\n', sum(mle_SA1.runTime));
%             iSave(sprintf(save_filename_template, 'MLEorder1SA', t, inputs_t.lambda), mle_SA1, inputs_t);
%         end

        if is_member('BOCS-MLE', implemented_algorithms)
            mle_SA2 = BOCS(inputs_t.model, penalty, inputs_t, 2, 'SA');
            fprintf('MLE.SA2 - Runtime = %f\n', sum(mle_SA2.runTime));
            iSave(sprintf(save_filename_template, 'MLEorder2SA', t, inputs_t.lambda), mle_SA2, inputs_t);
        end

%         if is_member('BOCS-MLE', implemented_algorithms)
%             mle_SA3 = BOCS(inputs_t.model, penalty, inputs_t, 3, 'SA');
%             fprintf('MLE.SA3 - Runtime = %f\n', sum(mle_SA3.runTime));
%             iSave(sprintf(save_filename_template, 'MLEorder3SA', t, inputs_t.lambda), mle_SA3, inputs_t);
%         end

        if is_member('BOCS-MLE', implemented_algorithms)
            mle_sdp = BOCS(inputs_t.model, penalty, inputs_t, 2, 'sdp');
            fprintf('MLE.SDP - Runtime = %f\n', sum(mle_sdp.runTime));
            iSave(sprintf(save_filename_template, 'MLEorder2SDP', t, inputs_t.lambda), mle_sdp, inputs_t);
        end

        % Run BOCS with Horseshoe model
        inputs_t.estimator = 'horseshoe';

%         if is_member('BOCS-HS', implemented_algorithms)
%             hs_SA1 = BOCS(inputs_t.model, penalty, inputs_t, 1, 'SA');
%             fprintf('HS.SA1 - Runtime = %f\n', sum(hs_SA1.runTime));
%             iSave(sprintf(save_filename_template, 'HorseShoeorder1SA', t, inputs_t.lambda), hs_SA1, inputs_t);
%         end

        if is_member('BOCS-HS', implemented_algorithms)
            hs_SA2 = BOCS(inputs_t.model, penalty, inputs_t, 2, 'SA');
            fprintf('HS.SA2 - Runtime = %f\n', sum(hs_SA2.runTime));
            iSave(sprintf(save_filename_template, 'HorseShoeorder2SA', t, inputs_t.lambda), hs_SA2, inputs_t);
        end

%         if is_member('BOCS-HS', implemented_algorithms)
%             hs_SA3 = BOCS(inputs_t.model, penalty, inputs_t, 3, 'SA');
%             fprintf('HS.SA3 - Runtime = %f\n', sum(hs_SA3.runTime));
%             iSave(sprintf(save_filename_template, 'HorseShoeorder3SA', t, inputs_t.lambda), hs_SA3, inputs_t);
%         end

        if is_member('BOCS-HS', implemented_algorithms)
            hs_SDP = BOCS(inputs_t.model, penalty, inputs_t, 2, 'sdp');
            fprintf('HS.SDP - Runtime = %f\n', sum(hs_SDP.runTime));
            iSave(sprintf(save_filename_template, 'HorseShoeorder2SDP', t, inputs_t.lambda), hs_SDP, inputs_t);
        end

    end
end

delete(gcp('nocreate'))