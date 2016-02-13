function runTrivialBaselineExperiments( datasetFile, expGroupIndex, nIterations )
% This function runs baseline experiments- page rank and in-degree node
% rank.
%   datasetFile - file name of the dataset
%   nExperiments - no of experiments
%   accuracyMeasure - accuracy measure to be used
    tic;
    % To make sure random no generation is different in parallel matalb
    % session
    rng('shuffle')
    
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
    nExperiments = dataset.nExpPerGroup;
    
    expTestAccuracyNDCG = cell(1,4);
    expTestAccuracyNDCG{1} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyNDCG{2} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyNDCG{3} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyNDCG{4} = zeros(nExperiments, dataset.nTypes + 1);
    
    
    expTestAccuracyAPAtTwenty = cell(1,4);
    expTestAccuracyAPAtTwenty{1} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtTwenty{2} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtTwenty{3} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtTwenty{4} = zeros(nExperiments, dataset.nTypes + 1);
    
    
    expTestAccuracyAPAtOneThird = cell(1,4);
    expTestAccuracyAPAtOneThird{1} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtOneThird{2} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtOneThird{3} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtOneThird{4} = zeros(nExperiments, dataset.nTypes + 1);
    
    expTestAccuracyAPAtN = cell(1,4);
    expTestAccuracyAPAtN{1} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtN{2} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtN{3} = zeros(nExperiments, dataset.nTypes + 1);
    expTestAccuracyAPAtN{4} = zeros(nExperiments, dataset.nTypes + 1);
    
    
    resultDir = fullfile(datasetFile,strcat('expGroup', num2str(expGroupIndex))); 
    
    
    % get the in-weight score based on referral matrix
    inWeightScore = sum(dataset.A,1).';
    
    % get the adjecency matrix 
    A = dataset.A > 0;
    
    % get in-degree based score for all the nodes
    inDegreeScore = sum(A,1).';
    
    % get the page rank for all the nodes
    pageRankScoreWeighted = PageRank(dataset.A, 0.85, nIterations);
    pageRankScore = PageRank(A, 0.85, nIterations);
    
    for experiment = 1 : nExperiments
        expTestAccuracyNDCG{1}(experiment, :) = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, inDegreeScore, '');
        expTestAccuracyNDCG{2}(experiment, :) = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, pageRankScoreWeighted, '');
        expTestAccuracyNDCG{3}(experiment, :) = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, pageRankScore, '');
        expTestAccuracyNDCG{4}(experiment, :) = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, inWeightScore, '');
        
        expTestAccuracyAPAtOneThird{1}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inDegreeScore, '1/3');
        expTestAccuracyAPAtOneThird{2}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScoreWeighted, '1/3');
        expTestAccuracyAPAtOneThird{3}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScore, '1/3');
        expTestAccuracyAPAtOneThird{4}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inWeightScore, '1/3');
        
        expTestAccuracyAPAtTwenty{1}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inDegreeScore, '20');
        expTestAccuracyAPAtTwenty{2}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScoreWeighted, '20');
        expTestAccuracyAPAtTwenty{3}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScore, '20');
        expTestAccuracyAPAtTwenty{4}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inWeightScore, '20');
        
        expTestAccuracyAPAtN{1}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inDegreeScore, 'N');
        expTestAccuracyAPAtN{2}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScoreWeighted, 'N');
        expTestAccuracyAPAtN{3}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, pageRankScore, 'N');
        expTestAccuracyAPAtN{4}(experiment, :) = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, inWeightScore, 'N');
        
        
    end
    
    xlswrite(fullfile(resultDir, 'PageRank_Te_NDCG.xlsx'), expTestAccuracyNDCG{3});
    xlswrite(fullfile(resultDir, 'PageRankWeighted_Te_NDCG.xlsx'), expTestAccuracyNDCG{2});
    xlswrite(fullfile(resultDir, 'InDegree_Te_NDCG.xlsx'), expTestAccuracyNDCG{1});
    xlswrite(fullfile(resultDir, 'InWeight_Te_NDCG.xlsx'), expTestAccuracyNDCG{4});
    
    xlswrite(fullfile(resultDir, 'PageRank_Te_APAtOneThird.xlsx'), expTestAccuracyAPAtOneThird{3});
    xlswrite(fullfile(resultDir, 'PageRankWeighted_Te_APAtOneThird.xlsx'), expTestAccuracyAPAtOneThird{2});
    xlswrite(fullfile(resultDir, 'InDegree_Te_APAtOneThird.xlsx'), expTestAccuracyAPAtOneThird{1});
    xlswrite(fullfile(resultDir, 'InWeight_Te_APAtOneThird.xlsx'), expTestAccuracyAPAtOneThird{4});
    
    
    xlswrite(fullfile(resultDir, 'PageRank_Te_APAtTwenty.xlsx'), expTestAccuracyAPAtTwenty{3});
    xlswrite(fullfile(resultDir, 'PageRankWeighted_Te_APAtTwenty.xlsx'), expTestAccuracyAPAtTwenty{2});
    xlswrite(fullfile(resultDir, 'InDegree_Te_APAtTwenty.xlsx'), expTestAccuracyAPAtTwenty{1});
    xlswrite(fullfile(resultDir, 'InWeight_Te_APAtTwenty.xlsx'), expTestAccuracyAPAtTwenty{4});
    
    xlswrite(fullfile(resultDir, 'PageRank_Te_APAtN.xlsx'), expTestAccuracyAPAtN{3});
    xlswrite(fullfile(resultDir, 'PageRankWeighted_Te_APAtN.xlsx'), expTestAccuracyAPAtN{2});
    xlswrite(fullfile(resultDir, 'InDegree_Te_APAtN.xlsx'), expTestAccuracyAPAtN{1});
    xlswrite(fullfile(resultDir, 'InWeight_Te_APAtN.xlsx'), expTestAccuracyAPAtN{4});
    
    
    xlswrite(fullfile(resultDir, 'PageRankScoreWeighted.xlsx'), pageRankScoreWeighted);
    xlswrite(fullfile(resultDir, 'InDegreeScore.xlsx'), inDegreeScore);
    xlswrite(fullfile(resultDir, 'PageRankScore.xlsx'), pageRankScore);
    xlswrite(fullfile(resultDir, 'InWeightScore.xlsx'), inWeightScore);
    toc
end

