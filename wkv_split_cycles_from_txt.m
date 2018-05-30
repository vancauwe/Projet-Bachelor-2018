function cycles = wkv_split_cycles_from_txt(wkv, indices, N)
%WKV_SPLIT_CYCLES_ Splits into sub-wkvs with a single cycle.
%   Splits the given wkv into individual cycles. The method is to strongly
%   filter the values corresponding to the splittingVar index, such that
%   they become a centered sine-like curve. The cutting point are where
%   this curve is crossing zero from a negative to a positive value.
%   The found cutting points can be shift by the phaseOffset [%].

%% Detect the cycles.

cycles = cell(N,1);

i=1; j=1;
while (i<length(indices))

    %the last indice is the one that defines if the step is a left or right
    %step. Indeed the indices indicate the END of a step
    
    %End right step time + end left step time = 1 LEFT step
    %same end left step time + end right step time = 1 RIGHT step
    %3 indices represent two steps and a full cycle
    cycles{j} = wkv_subset(wkv, (indices(i):indices(i+2)));
    i=i+2;
    j=j+1;
end

end
