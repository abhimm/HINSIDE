function runModelDBLP( datasetFile, expGroupIndex )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    tStart = tic;    
    % To make sure random no generation is different in parallel matalb
    % session
    rng('shuffle')
%     if cvx == 1
% %         c = parcluster('local');
% %         c.NumWorkers = 3;
% %         poolObj = parpool(c, c.NumWorkers);
%         matlabpool OPEN 2 
%     end
    
    % create dataset object
    dataset = Dataset;
    
    % generate necessary matrix
    [ dataset.groundTruthGamma, dataset.groundTruthR, ....
        dataset.groundTruthRankingCell, dataset.groundTruthPartialRankCell,...
        dataset.A, dataset.D, dataset.E, dataset.M, dataset.P, ...
        dataset.T, dataset.Type, dataset.nNodes, ...
        dataset.nTypes, dataset.nExpPerGroup ] = initializeExperiment( datasetFile, expGroupIndex );
    %%%%% Here n = no of nodes, m = no of types, A = adjacency matrix, M =
    %%%%% A.*D, D = distance matric containing indices, T= n x m type
    %%%%% matrix, Type = 1 x n type matrix, E = n x n matrix where E(i,j)=1
    %%%%% if type(i) = type(j) and i != j, P = proximity matrix based on
    %%%%% BOX of 20 miles
    
    
    toc(tStart) 
end

