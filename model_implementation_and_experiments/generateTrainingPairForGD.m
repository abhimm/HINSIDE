function [ trainingPairs ] = generateTrainingPairForGD( trainingList, equation )
% This function generates training pairs from the training list.
%   Input argument-
%       trainingList - a list containing nodes and their rank score.
%   Output arugment - 
%       trainingPairs - a list containing tuple where first two elements 
%                       are nodes ordered based on their scores
    trainingList = sortrows(trainingList, -2);
    nodeList = trainingList(:, 1);
    trainingNodePairs = nchoosek(nodeList, 2);
    if equation == 1
        % for equation, we need sigmoid of ri - rj for all pair (i, j) such
        % that i != j 
        trainingNodePairs = [trainingNodePairs; trainingNodePairs(:,2) trainingNodePairs(:,1)];
        
        [~, iIndex] = ismember(trainingNodePairs(:,1), nodeList);
        [~, jIndex] = ismember(trainingNodePairs(:,2), nodeList);
        
        % calculate ri - rj
        rij = trainingList(iIndex, 2) - trainingList(jIndex, 2);
        
        % calculate sigmoid of ri - rj
        pijGroundTruth = exp(rij);
        pijGroundTruth = pijGroundTruth ./ (1 + pijGroundTruth);
        
        % generate training pairs
        trainingPairs = [trainingNodePairs(:,1) trainingNodePairs(:,2) pijGroundTruth(:,:)];
    elseif equation == 2
        % for equation 2, we just need ordered pair of nodes.
        trainingPairs = trainingNodePairs;
    end
    
end

