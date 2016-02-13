function runModelDBLP( datasetFile, expGroupIndex)
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
    
    % create equal value gamma
    equalGamma = ones(dataset.nTypes);
    
    % get the rank score
    r = powerIteration(equalGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);
    accuracyNDCG = computeAccuracy('NDCG', dataset.groundTruthRankingCell{1}, r, '');
    accuracyAPOneThird = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, '1/3');
    accuracyAPTwenty = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, '20');
    accuracyAPN = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, 'N');
    
    
    resultDir = fullfile(datasetFile,strcat('expGroup', num2str(expGroupIndex)));
    
    xlswrite(fullfile(resultDir, 'equalGammaAccuracyNDCG.xlsx'),accuracyNDCG);
    xlswrite(fullfile(resultDir, 'equalGammaAccuracyAPOneThird.xlsx'),accuracyAPOneThird);
    xlswrite(fullfile(resultDir, 'equalGammaAccuracyAPTwenty.xlsx'),accuracyAPTwenty);
    xlswrite(fullfile(resultDir, 'equalGammaAccuracyAPN.xlsx'),accuracyAPN);
    
    saveRanking(fullfile(resultDir, 'equalGammaBestRCell.xlsx'), GeneratePartialRanking(r, dataset.Type, dataset.nNodes, dataset.nTypes, 1, 1), dataset.nNodes, dataset.nTypes);
    
    toc(tStart) 
end

