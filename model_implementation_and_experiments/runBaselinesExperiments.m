function runBaselinesExperiments( datasetFile, expGroupIndex, nRuns )
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
    
    
    % Create variables for best results
    bestTrainAccuracyNDCG = cell(1, 2);
    bestTestAccuracyNDCG = cell(1, 2);
    expTrainingAccuracyAllNDCG = cell(1, 2);
    expTestAccuracyAllNDCG = cell(1, 2);
    
    bestTrainAccuracyAPAtOneThird = cell(1, 2);
    bestTestAccuracyAPAtOneThird = cell(1, 2);
    expAllGamma = cell(dataset.nExpPerGroup, nRuns);
    expAllRandomeGuessingR = cell(dataset.nExpPerGroup, nRuns);
    expTrainingAccuracyAllAPAtOneThird = cell(1, 2);
    expTestAccuracyAllAPAtOneThird = cell(1, 2);
    
    bestTrainAccuracyAPAtTwenty = cell(1, 2);
    bestTestAccuracyAPAtTwenty = cell(1, 2);
    
    expTrainingAccuracyAllAPAtTwenty = cell(1, 2);
    expTestAccuracyAllAPAtTwenty = cell(1, 2);
    
    
    
    bestGamma = cell(1, 2);
    bestR = cell(1, 2);
    
    
    bestTestAccuracyNDCG{1} = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    bestTestAccuracyNDCG{2} = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    
    bestTrainAccuracyNDCG{1} = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    bestTrainAccuracyNDCG{2} = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    
    bestR{1} = zeros(dataset.nNodes, dataset.nExpPerGroup);
    bestR{2} = zeros(dataset.nNodes, dataset.nExpPerGroup);
    
    bestGamma{1} = zeros( (dataset.nTypes + 1)*dataset.nExpPerGroup , dataset.nTypes);
    bestGamma{2} = zeros( (dataset.nTypes + 1)*dataset.nExpPerGroup , dataset.nTypes);
    
    expTrainingAccuracyAllNDCG{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTrainingAccuracyAllNDCG{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTrainingAccuracyAllAPAtOneThird{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTrainingAccuracyAllAPAtOneThird{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTrainingAccuracyAllAPAtTwenty{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTrainingAccuracyAllAPAtTwenty{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);

    expTestAccuracyAllNDCG{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTestAccuracyAllNDCG{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTestAccuracyAllAPAtOneThird{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTestAccuracyAllAPAtOneThird{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTestAccuracyAllAPAtTwenty{1} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    expTestAccuracyAllAPAtTwenty{2} = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    counter = 1;
    accuracyCounter = 1;
    
    for experiment = 1 : dataset.nExpPerGroup
        expBestTrNDCG = cell(2, 1);
        expBestTrAPAtOneThird = cell(2, 1);
        
        expBestTrNDCG{1} = zeros(1, dataset.nTypes + 1);
        expBestTrNDCG{2} = zeros(1, dataset.nTypes + 1);
        
        expBestTrAPAtOneThird{1} = zeros(1, dataset.nTypes + 1);
        expBestTrAPAtOneThird{2} = zeros(1, dataset.nTypes + 1);
        
        expBestTrAPAtTwenty{1} = zeros(1, dataset.nTypes + 1);
        expBestTrAPAtTwenty{2} = zeros(1, dataset.nTypes + 1);
        
        expBestTeNDCG = cell(2, 1);
        expBestTeNDCG{1} = zeros(1, dataset.nTypes + 1);
        expBestTeNDCG{2} = zeros(1, dataset.nTypes + 1);
        
        expBestTeAPAtOneThird = cell(2, 1);
        expBestTeAPAtOneThird{1} = zeros(1, dataset.nTypes + 1);
        expBestTeAPAtOneThird{2} = zeros(1, dataset.nTypes + 1);
        
        expBestTeAPAtTwenty = cell(2, 1);
        expBestTeAPAtTwenty{1} = zeros(1, dataset.nTypes + 1);
        expBestTeAPAtTwenty{2} = zeros(1, dataset.nTypes + 1);
        
        expBestGamma = cell(2, 1);
        expBestGamma{1} = zeros(dataset.nTypes);
        expBestGamma{2} = zeros(dataset.nTypes);
        
        expBestR = cell(2, 1);
        expBestR{1} = zeros();
        expBestR{2} = zeros();
        
        for run = 1: nRuns
            % initilze gamma with random values for random guessing of
            % gamma baseline
            randomGuessedGamma = rand(dataset.nTypes)*10;
            expAllGamma{experiment, run} = randomGuessedGamma;
            % normalize gamma
            %randomGuessedGamma = randomGuessedGamma./ repmat(sum(abs(randomGuessedGamma), 2), 1, size(randomGuessedGamma,2));
            % get ranking based on randomly guessed gamma
            rRandomGuessedGamma = powerIteration( randomGuessedGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P); 
            
            expAllRandomeGuessingR{experiment, run} = rRandomGuessedGamma;
            
            %get training accuracy for random guessing og gamma
            rgTrNDCG = computeAccuracy('NDCG', dataset.groundTruthPartialRankCell{experiment}, rRandomGuessedGamma, '');
            rgTrAPAtOneThird = computeAccuracy('AP', dataset.groundTruthPartialRankCell{experiment}, rRandomGuessedGamma, '1/3');
            rgTrAPAtTwenty = computeAccuracy('AP', dataset.groundTruthPartialRankCell{experiment}, rRandomGuessedGamma, '20');
            
            expTrainingAccuracyAllNDCG{1}(accuracyCounter, :) = rgTrNDCG;
            expTrainingAccuracyAllAPAtOneThird{1}(accuracyCounter, :) = rgTrAPAtOneThird;
            expTrainingAccuracyAllAPAtTwenty{1}(accuracyCounter, :) = rgTrAPAtTwenty;
            
            % get test accuracy for random guessing of gamma
            rgTeNDCG = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, rRandomGuessedGamma, '');
            rgTeAPAtOneThird = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, rRandomGuessedGamma, '1/3');
            rgTeAPAtTwenty = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, rRandomGuessedGamma, '20');
            
            expTestAccuracyAllNDCG{1}(accuracyCounter, :) = rgTeNDCG;
            expTestAccuracyAllAPAtOneThird{1}(accuracyCounter, :) = rgTeAPAtOneThird;
            expTestAccuracyAllAPAtTwenty{1}(accuracyCounter, :) = rgTeAPAtTwenty;
            
            %get permuted ranking for randomly ordered baseline
            rRandomOrdered = randperm(dataset.nNodes);
            rRandomOrdered = rRandomOrdered.';
            
            %get training accuracy for random ordering
            roTrNDCG = computeAccuracy('NDCG', dataset.groundTruthPartialRankCell{experiment}, rRandomOrdered, '');
            roTrAPAtOneThird = computeAccuracy('AP', dataset.groundTruthPartialRankCell{experiment}, rRandomOrdered, '1/3');
            roTrAPAtTwenty = computeAccuracy('AP', dataset.groundTruthPartialRankCell{experiment}, rRandomOrdered, '20');
            
            expTrainingAccuracyAllNDCG{2}(accuracyCounter, :) = roTrNDCG;
            expTrainingAccuracyAllAPAtOneThird{2}(accuracyCounter, :) = roTrAPAtOneThird;
            expTrainingAccuracyAllAPAtTwenty{2}(accuracyCounter, :) = roTrAPAtTwenty;
            
            % get test accuracy for random guessing of gamma
            roTeNDCG = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, rRandomOrdered, '');
            roTeAPAtOneThird = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, rRandomOrdered, '1/3');
            roTeAPAtTwenty = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, rRandomOrdered, '20');
            
            expTestAccuracyAllNDCG{2}(accuracyCounter, :) = roTeNDCG;
            expTestAccuracyAllAPAtOneThird{2}(accuracyCounter, :) = roTeAPAtOneThird;
            expTestAccuracyAllAPAtTwenty{2}(accuracyCounter, :) = roTeAPAtTwenty;
            
            if rgTrAPAtOneThird(dataset.nTypes + 1) - expBestTrAPAtOneThird{1}(dataset.nTypes + 1)> 0
                expBestTrNDCG{1} = rgTrNDCG;
                expBestTrAPAtOneThird{1} = rgTrAPAtOneThird;
                expBestTrAPAtTwenty{1} = rgTrAPAtTwenty;
                
                expBestTeNDCG{1} = rgTeNDCG;
                expBestTeAPAtOneThird{1} = rgTeAPAtOneThird;
                expBestTeAPAtTwenty{1} = rgTeAPAtTwenty;
                
                expBestGamma{1} = randomGuessedGamma;
                expBestR{1} = rRandomGuessedGamma;
            end
            if roTrAPAtOneThird(dataset.nTypes + 1) - expBestTrAPAtOneThird{2}(dataset.nTypes + 1)> 0
                expBestTrNDCG{2} = roTrNDCG;
                expBestTeNDCG{2} = roTeNDCG;
                
                expBestTrAPAtOneThird{2} = roTrAPAtOneThird;
                expBestTeAPAtOneThird{2} = roTeAPAtOneThird;
                
                expBestTrAPAtTwenty{2} = roTrAPAtTwenty;
                expBestTeAPAtTwenty{2} = roTeAPAtTwenty;
                
                expBestR{2} = rRandomOrdered;
            end
            accuracyCounter = accuracyCounter + 1;
        end
        
        
        for j = 1 : dataset.nTypes
            bestGamma{1}(counter,:) = expBestGamma{1}(j,:);
            bestGamma{2}(counter,:) = expBestGamma{2}(j,:);
            counter = counter + 1;
        end
        counter = counter + 1;
        accuracyCounter = accuracyCounter + 1;
        
        bestTestAccuracyNDCG{1}(experiment, :) = expBestTeNDCG{1};
        bestTestAccuracyNDCG{2}(experiment, :) = expBestTeNDCG{2};
        
        bestTrainAccuracyNDCG{1}(experiment, :) = expBestTrNDCG{1};
        bestTrainAccuracyNDCG{2}(experiment, :) = expBestTrNDCG{2};
              
        bestTestAccuracyAPAtOneThird{1}(experiment, :) = expBestTeAPAtOneThird{1};
        bestTestAccuracyAPAtOneThird{2}(experiment, :) = expBestTeAPAtOneThird{2};
        
        bestTrainAccuracyAPAtOneThird{1}(experiment, :) = expBestTrAPAtOneThird{1};
        bestTrainAccuracyAPAtOneThird{2}(experiment, :) = expBestTrAPAtOneThird{2};
        
        
        bestTestAccuracyAPAtTwenty{1}(experiment, :) = expBestTeAPAtTwenty{1};
        bestTestAccuracyAPAtTwenty{2}(experiment, :) = expBestTeAPAtTwenty{2};
        
        bestTrainAccuracyAPAtTwenty{1}(experiment, :) = expBestTrAPAtTwenty{1};
        bestTrainAccuracyAPAtTwenty{2}(experiment, :) = expBestTrAPAtTwenty{2};
        
        bestR{1}(:, experiment) = expBestR{1};
        bestR{2}(:, experiment) = expBestR{2};
    end
    
    resultDir = fullfile(datasetFile,strcat('expGroup', num2str(expGroupIndex))); 
    
    for algorithm = 1 : 2
        if algorithm == 1
            algoName = 'RandomGamma_';
        else
            algoName = 'RandomOrder_';
            bestTestAccuracyNDCG{algorithm}
        end
        
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrNDCG.xlsx')), bestTrainAccuracyNDCG{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeNDCG.xlsx')), bestTestAccuracyNDCG{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllNDCG.xlsx')),expTrainingAccuracyAllNDCG{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllNDCG.xlsx')),expTestAccuracyAllNDCG{algorithm});


        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAPAtOneThird.xlsx')), bestTrainAccuracyAPAtOneThird{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAPAtOneThird.xlsx')), bestTestAccuracyAPAtOneThird{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllAPAtOneThird.xlsx')),expTrainingAccuracyAllAPAtOneThird{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllAPAtOneThird.xlsx')),expTestAccuracyAllAPAtOneThird{algorithm});
        
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAPAtTwenty.xlsx')), bestTrainAccuracyAPAtTwenty{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAPAtTwenty.xlsx')), bestTestAccuracyAPAtTwenty{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllAPAtTwenty.xlsx')),expTrainingAccuracyAllAPAtTwenty{algorithm});
        xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllAPAtTwenty.xlsx')),expTestAccuracyAllAPAtTwenty{algorithm});

        for experiment = 1 : dataset.nExpPerGroup
            xlswrite(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestGamma.xlsx')), bestGamma{experiment});
            xlswrite(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestR.xlsx')), bestR{experiment});
            saveRanking(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestRCell.xlsx')), GeneratePartialRanking(bestR{experiment}, dataset.Type, dataset.nNodes, dataset.nTypes, 1, 1), dataset.nNodes, dataset.nTypes);
            % capture rankings and gamma for every run of every experiment
            %if algorithm == 1 
             %   for run = 1 : nRuns
              %      xlswrite(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'run', int2str(run) , '_', 'Gamma.xlsx')), expAllGamma{experiment, run});
               %     saveRanking(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'run', int2str(run), '_', 'R.xlsx')), GeneratePartialRanking(expAllRandomeGuessingR{experiment, run}, dataset.Type, dataset.nNodes, dataset.nTypes, 1, 1), dataset.nNodes, dataset.nTypes);
                %end
           % end
        end
 
    end
    toc
end

