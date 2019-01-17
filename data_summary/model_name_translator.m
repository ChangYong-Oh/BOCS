function [translated_model_name] = model_name_translator(model_name)
    my_naming = my_model_names();
    bocs_naming = bocs_model_names();
    if any(strcmp(bocs_naming, model_name))
        translated_model_name = bocs_naming_to_my_naming(model_name);
    elseif any(strcmp(my_naming, model_name))
        translated_model_name = model_name;
    else
        error('Not proper model name')
    end
end


function [my_name] = bocs_naming_to_my_naming(bocs_name)
    if strcmp(bocs_name, 'rnd')
        my_name = 'RandomSearch';
    elseif strcmp(bocs_name, 'sa')
        my_name = 'SimulatedAnnealing';
    elseif strcmp(bocs_name, 'sa')
        my_name = 'SimulatedAnnealing';
    elseif strcmp(bocs_name, 'bo')
        my_name = 'ExpectedImprovement';
    elseif strcmp(bocs_name, 'ols')
        my_name = 'SimulatedAnnealing';
    elseif strcmp(bocs_name, 'smc')
        my_name = 'SequentialMonteCarlo';
    elseif strcmp(bocs_name, 'smac')
        my_name = 'SMAC';
    elseif strcmp(bocs_name, 'bayes-sa')
        my_name = 'BOCSorder2SA';
    elseif strcmp(bocs_name, 'bayes-sdp')
        my_name = 'BOCSorder2SDP';
    elseif strcmp(bocs_name, 'mle-sa')
        my_name = 'MLEorder2SA';
    elseif strcmp(bocs_name, 'mle-sdp')
        my_name = 'MLEorder2SDP';
    elseif strcmp(bocs_name, 'hs-sa')
        my_name = 'HorseShoeorder2SA';
    elseif strcmp(bocs_name, 'hs-sdp')
        my_name = 'HorseShoeorder2SDP';
    end
end
