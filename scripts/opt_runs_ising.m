%
% Bayesian Optimization of Combinatorial Structures
%
% Copyright (C) 2018 R. Baptista & M. Poloczek
%
% BOCS is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% BOCS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License 
% along with BOCS.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright (C) 2018 MIT & University of Arizona
% Authors: Ricardo Baptista & Matthias Poloczek
% E-mails: rsb@mit.edu & poloczek@email.arizona.edu
%

% Script runs discrete optimization algorithms for the
% Ising model sparsification problem. The results are 
% compared for different values of the \lambda tuning 
% parameter.

function [] = opt_runs_ising(algorithms)
current_file_dir = strsplit(mfilename('fullpath'), '/');
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'algorithms'], '/')]));
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'stat_model'], '/')]));
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'test_problems', 'IsingModel'], '/')]));
addpath(strcat(['/', strjoin([current_file_dir(2:end-2), 'tools'], '/')]));

%% Setup parameters

% Setup fixed parameters
n_nodes = 16;
% n_vars  = 24;
n_proc  = 1;
test_name = 'ising';

% Number of runs and optimization iterations
% n_func     = 5;
% n_runs     = 5;
% n_init     = 20;
evalBudget = 170;

% Variance prior parameters (Inverse Gamma)
aPr    = 2;
bPr    = 1;

% Regularization parameters
lambda_vals = [0, 1e-4, 1e-2];
lambda_str  = {'0', '1em4', '1em2'};

% Set additive regularization function
reg_term = @(x) sum(x,2);

%% Generate Test Cases

% random data file preprocess
file_info_cell = dir(strcat(['/', strjoin([current_file_dir(2:end-2), 'random_data'], '/')]));
seed_numbers = [];
for f=1:size(file_info_cell, 1)
    if ~isempty(strfind(file_info_cell(f).name, test_name))
        seed_info = strsplit(file_info_cell(f).name(1:end-4), '_');
        seed_numbers = [seed_numbers; [str2num(cell2mat(seed_info(2))) str2num(cell2mat(seed_info(3)))]];
    end
end
[~, idx] = sort(seed_numbers(:, 1));
seed_numbers = seed_numbers(idx, :);
func_seeds = unique(seed_numbers(:, 1));

n_func = size(func_seeds, 1);
n_runs = sum(seed_numbers(:, 1) == func_seeds(1));

% setup objective functions
inputs_all = cell(n_func, n_runs);

for t1=1:n_func

    fprintf('Setting up test function %d\n', t1);
    func_seed = func_seeds(t1);
    init_seeds = sort(seed_numbers(seed_numbers(:, 1) == func_seed, 2));

    % Generate random graphical model
%     Theta   = rand_ising_grid(n_nodes);
%     Moments = ising_model_moments(Theta);
    
    for t2=1:n_runs
        init_seed = init_seeds(t2);
        
        data_file_name = strjoin({test_name, num2str(func_seed,'%04.f'), strcat(num2str(init_seed,'%04.f'), '.mat')}, '_');
        load(strcat('/', strjoin([current_file_dir(2:end-2), 'random_data', data_file_name], '/')));
        Theta = double(Theta);
        Moments = ising_model_moments(Theta);
        n_init = size(x_vals, 1);
        n_vars = size(x_vals, 2);
        
        % Set inputs struct for each problem
        inputs_all{t1,t2} = struct;
        inputs_all{t1,t2}.n_vars      = n_vars;

        % Save other definitions
        inputs_all{t1,t2}.evalBudget  = evalBudget;
        inputs_all{t1,t2}.n_runs      = n_runs;
        inputs_all{t1,t2}.n_init      = n_init;
        inputs_all{t1,t2}.lambda_vals = lambda_vals;

        % Set priors for estimator
        inputs_all{t1,t2}.aPr         = aPr;
        inputs_all{t1,t2}.bPr         = bPr;

        % Save objective function and regularization term
        inputs_all{t1,t2}.model = @(x) KL_divergence_ising(Theta, Moments, x);
        inputs_all{t1,t2}.reg_term = @(x) reg_term(x);

        % Generate initial samples for statistical models
        % inputs_all{t1,t2}.x_vals = sample_models(n_init, n_vars);
        inputs_all{t1,t2}.x_vals = double(x_vals);
        inputs_all{t1,t2}.y_vals = inputs_all{t1,t2}.model(inputs_all{t1,t2}.x_vals);

    end
end

inputs_all = reshape(inputs_all, n_func*n_runs, 1);

% Make folder
mkdir(['../results/' test_name])

% Save test cases
save(['../results/' test_name '/all_tests'])

% Run cases
run_cases(inputs_all, lambda_vals, test_name, n_proc, algorithms);
end
% -- END OF FILE --
