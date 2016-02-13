function [ NDCG ] = computeRankScoreBasedNDCG( groundTruthRankingList, resultRankScore )
% This function computes NDCG measure 
% Input Argument - 
%   groundTruthRankingList - a list containing the node and its ranking
%   score
%   resultRank - a list containing rank score of every node 
% Output Argument -
%   NDCG score.

    nNodes = size(groundTruthRankingList,1);
    groundTruthRankingList = sortrows(groundTruthRankingList, -2);
    groundTruthRankingList(:,2) = groundTruthRankingList(:, 2)*1000;
    resultRankList = [(1:size(resultRankScore,1)).' resultRankScore];
    resultRankList = sortrows(resultRankList, -2);
   
    resultNodes = resultRankList(:,1);
    
    groundTruthNodes = groundTruthRankingList(:, 1);
    
    [~, index] = ismember(resultNodes, groundTruthNodes);
    resultRank = index(index > 0);
        
    resultRelevanceScore = 2.^groundTruthRankingList(resultRank, 2).' - 1;
    groundTruthRelevanceScore = 2.^groundTruthRankingList(:, 2).' - 1;

    reductionFactor = 1 ./ [log2((1:nNodes) + 1)].';
    
    DCG = resultRelevanceScore*reductionFactor;
    IDCG = groundTruthRelevanceScore*reductionFactor;
    
    NDCG = DCG/IDCG;
end

