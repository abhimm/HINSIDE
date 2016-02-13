function [ AP ] = computeRankScoreBasedAP( groundTruthRankingList, resultRankScore, X  )
% This function computes average precision @ X measure 
% Input Argument - 
%   groundTruthRankingList - a list containing the node and its ranking
%   score
%   resultRank - a list containing rank score of every node 
%   X - position
% Output Argument -
%   AP@X score.
    % sort the ground truth rank list based on scores
    nNodes = size(groundTruthRankingList,1);
%     if X < 20
%         X = 20;
%     elseif X > 75
%         X = 75;
%     end
%     
    % Update no. of position requested, if required
    if X > nNodes
        X = nNodes;
    end
    X = double(X);
    groundTruthRankingList = sortrows(groundTruthRankingList, -2);

    % create result rank list 
    resultRankList = [(1:size(resultRankScore,1)).' resultRankScore];
    resultRankList = sortrows(resultRankList, -2);
   
    groundTruthNodeList = groundTruthRankingList(:,1);
    resultNodeList = resultRankList(:,1);
    
    % remove all the nodes from the result node list which are not present
    % in groundTruthList
    [isPresent, ~] = ismember(resultNodeList, groundTruthNodeList);
    resultNodeList = resultNodeList(isPresent > 0);
    precision = zeros(1,X);
    for position = 1 : X
        relevantNodes = ismember(resultNodeList(1:position, :), groundTruthNodeList(1:position, :));
        precision(1,position) = sum(relevantNodes)/position;
    end
    AP = sum(precision)/X;
end

