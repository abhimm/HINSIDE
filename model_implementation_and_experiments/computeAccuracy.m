function [ accuracy ] = computeAccuracy( accuracyMeasure, groundTruthRankingCell, resultRankScore, precision)
% This function computes the accuracy of resultant rank score for all nodes
% with respect to ground truth.
%   Input arguments - 
%       accuracyMeasure - measure: NDCG or MAP
%       groundTruthRankingCell - a cell array of size 1 x (no of types + 1),
%       containing ground truth rank score for every type and average accuracy
%       across the types
%       precision - required if accuracy measure is AP
%   Output Arguments - 
%       accuracy - a list of size`1 x no. of types containing
%                  accuracy for every type.
    % get no of types
    nTypes = size(groundTruthRankingCell, 2);
    
    % intialize accuracy list
    accuracy = zeros(1, nTypes);
    for type = 1:nTypes
        if strcmp(accuracyMeasure, 'NDCG') == 1
            accuracy(type) = computeRankScoreBasedNDCG(groundTruthRankingCell{type}{1}, resultRankScore);
        elseif strcmp(accuracyMeasure, 'MAP') == 1
            % Not Implemented
        elseif strcmp(accuracyMeasure, 'AP') == 1
            if strcmp(precision, '1/3') == 1
                accuracy(type) = computeRankScoreBasedAP(groundTruthRankingCell{type}{1}, resultRankScore, uint32(0.33 * size(groundTruthRankingCell{type}{1}, 1)));
            elseif strcmp(precision, '20') == 1
                accuracy(type) = computeRankScoreBasedAP(groundTruthRankingCell{type}{1}, resultRankScore, 20);
            elseif strcmp(precision, 'N') == 1
                accuracy(type) = computeRankScoreBasedAP(groundTruthRankingCell{type}{1}, resultRankScore, size(groundTruthRankingCell{type}{1}, 1));
                
            end    
        end
    end
    accuracy(nTypes+1) = sum(accuracy(1:nTypes))/nTypes;

end