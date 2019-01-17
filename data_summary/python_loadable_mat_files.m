ising_src_dir = '/home/coh1/git_repositories/BOCS/results/ising';
ising_dst_dir = '/home/coh1/Experiments/CombinatorialBO/Ising_Others_python_friendly_mat_files';
contamination_src_dir = '/home/coh1/Experiments/CombinatorialBO/Contamination_Others';
contamination_dst_dir = '/home/coh1/Experiments/CombinatorialBO/Contamination_Others_python_friendly_mat_files';

algorithms_in_bocs_naming = bocs_model_names();
algorithms_in_my_naming = my_model_names();

for i=1:numel(algorithms_in_bocs_naming)
    model_name_in_bocs_naming = algorithms_in_bocs_naming{i};
    % lambda 0.0, 1e-4, 1e-2
    [data1, data2, data3] = summary_group_files(model_name_in_bocs_naming, ising_src_dir);
    model_name_in_my_naming = model_name_translator(model_name_in_bocs_naming);
    if ~any(strcmp(model_name_in_my_naming, algorithms_in_my_naming))
        error('Naming translation error.')
    end
    evaluation = data1;
    save([ising_dst_dir, '/', 'ising_', model_name_in_my_naming, '0E+00.mat'], 'evaluation');
    evaluation = data2;
    save([ising_dst_dir, '/', 'ising_', model_name_in_my_naming, '1E-04.mat'], 'evaluation');
    evaluation = data3;
    save([ising_dst_dir, '/', 'ising_', model_name_in_my_naming, '1E-02.mat'], 'evaluation');
end


for i=1:numel(algorithms_in_my_naming)
    model_name_in_my_naming = algorithms_in_my_naming{i};
    % lambda 0.0, 1e-4, 1e-2
    [data1, data2, data3] = summary_individual_files(model_name_in_my_naming, contamination_src_dir);
    evaluation = data1;
    save([contamination_dst_dir, '/', 'contamination_', model_name_in_my_naming, '0E+00.mat'], 'evaluation');
    evaluation = data2;
    save([contamination_dst_dir, '/', 'contamination_', model_name_in_my_naming, '1E-04.mat'], 'evaluation');
    evaluation = data3;
    save([contamination_dst_dir, '/', 'contamination_', model_name_in_my_naming, '1E-02.mat'], 'evaluation');
end