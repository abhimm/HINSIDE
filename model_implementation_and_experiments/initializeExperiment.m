function [ groundTruthGamma, groundTruthR, groundTruthRankingCell, groundTruthPartialRankCell, A, D, E, M, P, T, Type, nNodes, nTypes, nExpPerGroup ] = initializeExperiment( dataset, expGroupIndex )
% This function intializes matrices used during experiment
% groundTruthGamma - Ground truth gamma values for all experiments in one
% experiment group.
% groundTruthR- ground truth Ranking corresponding to ground truth gamma
% groundTruthRankingCell - ground truth ranking cell generated from groundTruthR
% A - referral matrix (nNodes x nNodes)
% D - Distance matrix 
% E - nNodes x nNodes
% M - A*D
% P - proximity matrix to decide local competition
% T - nNodes x nNodes matrix providing type information
% Type - nNodes x 1 providing type information
% nNodes
% nTypes
% nExpPerGroup - no. of experiments

    % load all matrices
    load(fullfile(dataset, 'experimentSetData.mat'), 'A', 'D', 'E', 'M', 'P', 'T', 'Type');
    load(fullfile(dataset, strcat('expGroup', num2str(expGroupIndex)), 'expGroupData.mat'), 'gamma', 'r', 'rankingCell', 'partialRankingCell');
    
    groundTruthGamma = gamma;
    groundTruthR = r;
    groundTruthRankingCell = rankingCell;
    groundTruthPartialRankCell = partialRankingCell;
    nNodes = size(Type,2);
    nTypes = max(Type);
    nExpPerGroup = size(groundTruthR, 1);
end

