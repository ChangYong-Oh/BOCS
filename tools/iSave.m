% Author: Ricardo Baptista and Matthias Poloczek
% Date:   June 2018
%
% See LICENSE.md for copyright information
%

function iSave(fname, var_name1, var_name2)
    [dirname, ~, ~] = fileparts(fname);
    dir_structure = strsplit(dirname, '/')
    for i = 2:size(dir_structure, 2)
        if ~exist(strjoin(dir_structure(1:i), '/'), 'dir')
            mkdir(strjoin(dir_structure(1:i), '/'));
        end
    end
	save(fname, var_name1, var_name2);
end
