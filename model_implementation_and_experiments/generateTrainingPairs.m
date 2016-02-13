function [ trainingPairs ] = generateTrainingPairs( trainingList )
% This function generates training pairs from the training list.
%   Input argument-
%       trainingList - a list containing nodes and their rank score.
%   Output arugment - 
%       trainingPairs - a list containing triplets where first two elements 
%                       are nodes and last element is ordering between
%                       those two nodes.
    trainingList = sortrows(trainingList, 2);
    nodeList = trainingList(:, 1);
    trainingPairs = nchoosek(nodeList,2);
    trainingPairs = [trainingPairs; trainingPairs(:, [2,1])];
    [~, nodePosition] = ismember(trainingPairs, nodeList, 'R2012a');
    trainingPairs = [trainingPairs sign(nodePosition(:,1) - nodePosition(:,2))];
    
end