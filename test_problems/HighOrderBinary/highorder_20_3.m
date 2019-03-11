function [ output ] = highorder_20_3( x, interaction1, coef1, interaction2, coef2, interaction3, coef3)
%HIGHORDER_20_3 Summary of this function goes here
%   Detailed explanation goes here
    output = 0;
    
    N1 = size(interaction1, 1);
    for i1 = 1:N1
        output = output + coef1(1, i1) * (sum(x(1:end, interaction1(i1, 1:end) + 1), 2) == 1);
    end
    
    N2 = size(interaction2, 1);
    for i2 = 1:N2
        output = output + coef2(1, i2) * (sum(x(1:end, interaction2(i2, 1:end) + 1), 2) == 2);
    end
    
    N3 = size(interaction3, 1);
    for i3 = 1:N3
        output = output + coef3(1, i3) * (sum(x(1:end, interaction3(i3, 1:end) + 1), 2) == 3);
    end
end

