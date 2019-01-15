function [membership] = is_member(member, set)
%IS_MEMBER Summary of this function goes here
%   Detailed explanation goes here
membership = false;
for i=1:numel(set)
    if strcmp(member, set(i))
        membership = true;
    end
end

