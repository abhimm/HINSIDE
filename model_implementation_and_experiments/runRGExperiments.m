function runRGExperiments( datasetFile, expGroupIndex, nRuns )
%This function executes the baseline algorithms for HINRANK.
%   Detailed explanation goes here

    tic;
    % To make sure random no generation is different in parallel matalb
    % session
    rng('shuffle')
    
    % create dataset object
    dataset = Dataset;
    
    % generate necessary matrix
    [ dataset.groundTruthGamma, dataset.groundTruthR, ...
        dataset.groundTruthRankingCell, dataset.groundTruthPartialRankCell,...
        dataset.A, dataset.D, dataset.E, dataset.M, dataset.P, dataset.T, ...
        dataset.Type, dataset.nNodes, dataset.nTypes, dataset.nExpPerGroup ] = initializeExperiment( datasetFile, expGroupIndex );
    %%%%% Here n = no of nodes, m = no of types, A = adjacency matrix, M =
    %%%%% A.*D, D = distance matric containing indices, T= n x m type
    %%%%% matrix, Type = 1 x n type matrix, E = n x n matrix where E(i,j)=1
    %%%%% if type(i) = type(j) and i != j, P = proximity matrix based on
    %%%%% BOX of 20 miles
    
    bestRunsTrainingAccuracyNDCG = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTrainingAccuracyAPAtOneThird = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTrainingAccuracyAPAtTwenty = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTrainingAccuracyAPAtN = zeros(nRuns/10, dataset.nTypes + 1);
    
    bestRunsTestAccuracyNDCG = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTestAccuracyAPAtOneThird = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTestAccuracyAPAtTwenty = zeros(nRuns/10, dataset.nTypes + 1);
    bestRunsTestAccuracyAPAtN = zeros(nRuns/10, dataset.nTypes + 1);
    
    bestTrainingAccuracyNDCG = zeros(1, dataset.nTypes + 1);
    bestTrainingAccuracyAPAtOneThird = zeros(1, dataset.nTypes + 1);
    bestTrainingAccuracyAPAtTwenty = zeros(1, dataset.nTypes + 1);
    bestTrainingAccuracyAPAtN = zeros(1, dataset.nTypes + 1);
    
    bestTestAccuracyNDCG = zeros(1, dataset.nTypes + 1);
    bestTestAccuracyAPAtOneThird = zeros(1, dataset.nTypes + 1);
    bestTestAccuracyAPAtTwenty = zeros(1, dataset.nTypes + 1);
    bestTestAccuracyAPAtN = zeros(1, dataset.nTypes + 1);
    
    interval = 1;
    for run = 1 : nRuns
        % initialize randome gamma
        randomGuessedGamma = rand(dataset.nTypes);
        r = powerIteration( randomGuessedGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P); 
        
        % get train accuracy for random guessing of gamma
        rgTrNDCG = computeAccuracy('NDCG', dataset.groundTruthPartialRankCell{1}, r, '');
        rgTrAPAtOneThird = computeAccuracy('AP', dataset.groundTruthPartialRankCell{1}, r, '1/3');
        rgTrAPAtTwenty = computeAccuracy('AP', dataset.groundTruthPartialRankCell{1}, r, '20');
        rgTrAPAtN = computeAccuracy('AP', dataset.groundTruthPartialRankCell{1}, r, 'N');
        
        if rgTrAPAtTwenty(dataset.nTypes + 1) > bestTrainingAccuracyAPAtTwenty(dataset.nTypes + 1)
            bestTrainingAccuracyAPAtN = rgTrAPAtN;
            bestTrainingAccuracyAPAtOneThird = rgTrAPAtOneThird;
            bestTrainingAccuracyAPAtTwenty = rgTrAPAtTwenty;
            bestTrainingAccuracyNDCG = rgTrNDCG;
            
            % get test accuracy for random guessing of gamma
            bestTestAccuracyNDCG = computeAccuracy('NDCG', dataset.groundTruthRankingCell{1}, r, '');
            bestTestAccuracyAPAtOneThird = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, '1/3');
            bestTestAccuracyAPAtTwenty = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, '20');
            bestTestAccuracyAPAtN = computeAccuracy('AP', dataset.groundTruthRankingCell{1}, r, 'N');
        end
        
        if run == interval*10
            bestRunsTestAccuracyAPAtN(interval, :) = bestTestAccuracyAPAtN;
            bestRunsTestAccuracyAPAtOneThird(interval, :) = bestTestAccuracyAPAtOneThird;
            bestRunsTestAccuracyAPAtTwenty(interval, :) = bestTestAccuracyAPAtTwenty;
            bestRunsTestAccuracyNDCG(interval, :) = bestTestAccuracyNDCG;

            bestRunsTrainingAccuracyAPAtN(interval, :) = bestTrainingAccuracyAPAtN;
            bestRunsTrainingAccuracyAPAtOneThird(interval, :) = bestTrainingAccuracyAPAtOneThird;
            bestRunsTrainingAccuracyAPAtTwenty(interval, :) = bestTrainingAccuracyAPAtTwenty;
            bestRunsTrainingAccuracyNDCG(interval, :) = bestTrainingAccuracyNDCG;

            interval = interval + 1;
        end
    end
    
    resultDir = fullfile(datasetFile,strcat('expGroup', num2str(expGroupIndex))); 
    
    xlswrite(fullfile(resultDir, 'rgBestRunsTrNDCG.xlsx'), bestRunsTrainingAccuracyNDCG);
    xlswrite(fullfile(resultDir, 'rgBestRunsTeNDCG.xlsx'), bestRunsTestAccuracyNDCG);

    xlswrite(fullfile(resultDir, 'rgBestRunsTrAPAtOneThird.xlsx'), bestRunsTrainingAccuracyAPAtOneThird);
    xlswrite(fullfile(resultDir, 'rgBestRunsTeAPAtOneThird.xlsx'), bestRunsTestAccuracyAPAtOneThird);

    xlswrite(fullfile(resultDir, 'rgBestRunsTrAPAtTwenty.xlsx'), bestRunsTrainingAccuracyAPAtTwenty);
    xlswrite(fullfile(resultDir, 'rgBestRunsTeAPAtTwenty.xlsx'), bestRunsTestAccuracyAPAtTwenty);
   
    xlswrite(fullfile(resultDir, 'rgBestRunsTrAPAtN.xlsx'), bestRunsTrainingAccuracyAPAtN);
    xlswrite(fullfile(resultDir, 'rgBestRunsTeAPAtN.xlsx'), bestRunsTestAccuracyAPAtN);
    
    toc
end

