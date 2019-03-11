function [ output ] = highorder_20_4( x, interaction1, coef1, interaction2, coef2, interaction3, coef3, interaction4, coef4)
%HIGHORDER_20_3 Summary of this function goes here
%   Detailed explanation goes here
    output = 0;
    
    N1 = size(interaction1, 1);
    for i1 = 1:N1
       output = output + coef1(i1) * (sum(x(1:end, interaction1(i1, 1:end) + 1), 2) == 1);
    end
    
    N2 = size(interaction2, 1);
    for i2 = 1:N2
       output = output + coef2(i2) * (sum(x(1:end, interaction2(i2, 1:end) + 1), 2) == 2);
    end
    
    N3 = size(interaction3, 1);
    for i3 = 1:N3
       output = output + coef3(i3) * (sum(x(1:end, interaction3(i3, 1:end) + 1), 2) == 3);
    end
    
    N4 = size(interaction4, 1);
    for i4 = 1:N4
       output = output + coef4(i4) * (sum(x(1:end, interaction4(i4, 1:end) + 1), 2) == 4);
    end
end

