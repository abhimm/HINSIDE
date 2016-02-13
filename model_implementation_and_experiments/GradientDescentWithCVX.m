function [ w ] = GradientDescentWithCVX( features, trainingPair, equation, nonNegativity  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    deltaFeatures = features(:, trainingPair(:, 1)) - features(:, trainingPair(:, 2));
    nTypes = size(features, 1);
    
    if equation == 1
        pijGroundTruth = trainingPair(:,3).';
        if nonNegativity == 1
            cvx_begin quiet
                variable w(nTypes);
                oij = w.'* deltaFeatures;
                minimize (sum( -1 .* pijGroundTruth .* oij + log(1 + exp(oij) ), 2))
                subject to
                    w >= 0;
            cvx_end
        else
            cvx_begin quiet
                variable w(nTypes);
                oij = w.'* deltaFeatures;
                minimize (sum( -1 .* pijGroundTruth .* oij + log(1 + exp(oij) ), 2));
            cvx_end    
        end
    elseif equation == 2
         if nonNegativity == 1
            cvx_begin quiet
                variable w(nTypes);
                oij = w.'* deltaFeatures;
                minimize (sum( -1 .* oij + log(1 + exp(oij) ), 2))
                subject to
                    w >= 0;
            cvx_end
         else
            cvx_begin quiet
                variable w(nTypes);
                oij = w.'* deltaFeatures;
                minimize (sum( -1 .* oij + log(1 + exp(oij) ), 2));
            cvx_end
         end    
    end
    w
end

