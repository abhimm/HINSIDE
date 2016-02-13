function runExperiment( datasetFile, expGroupIndex, algorithm, nRuns, K, nIteration, isNonnegative, isLocalGD, equation, checkConvergence, cvx)
%This function performs the experiments for HINRANK.
% datasetFile: Path to experiment set folder
% expGroupIndex: index of the experiment group to be executed
% algorithm: 1 for SVM, 2 for GD
% nRuns:  no of runs to be performed, this represent random intiliazation of authority transfer rate which is estimated by the algorithm eventually
% K: K of K-fold cross-validation,
% nIteration: no iteration to be performed in alterating estimation of ATR,
% isNonnegative: 1 if non-negativity constrain, 0 if no constraint
% isLocalGD: at present keep always 1 (USED FOR GD)
% equation: 1 or 2 for two different formulation (USED FOR GD)
% checkConvergence: used for convergence check (not required) (USED FOR GD, keep always 0),
% cvx : 1, if GD has to be solved using convex optimization (not required, keep always 0)
%   
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
    expConvergenceInfo = zeros(dataset.nExpPerGroup*(nRuns + 1), 1);
    
    expTrainingAccuracyNDCG  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTrainingAccuracyAllNDCG  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTrainingAccuracyAPOneThird  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTrainingAccuracyAllAPOneThird  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTrainingAccuracyAPTwenty  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTrainingAccuracyAllAPTwenty  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
 
    expTrainingAccuracyAPN  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTrainingAccuracyAllAPN  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    
    expTestAccuracyNDCG  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTestAccuracyAllNDCG  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTestAccuracyAPOneThird  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTestAccuracyAPAllAPOneThird  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);
    
    expTestAccuracyAPTwenty  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTestAccuracyAPAllAPTwenty  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);

    expTestAccuracyAPN  = zeros(dataset.nExpPerGroup, dataset.nTypes + 1);
    expTestAccuracyAPAllAPN  = zeros(dataset.nExpPerGroup*(nRuns + 1), dataset.nTypes + 1);

    expBestGamma = cell(dataset.nExpPerGroup, 1);
    expBestR = cell(dataset.nExpPerGroup,1);
    counter = 1;
    resultDir = fullfile(datasetFile,strcat('expGroup', num2str(expGroupIndex))); 
    
    for experiment = 1:dataset.nExpPerGroup
        % initialize best results 
        bestGamma = zeros(dataset.nTypes);
        
        bestR = zeros(dataset.nNodes, 1);
        
        bestTrainingAccuracyNDCG = zeros(1, dataset.nTypes + 1);
        bestTrainingAccuracyAPOneThird = zeros(1, dataset.nTypes + 1);
        bestTrainingAccuracyAPTwenty = zeros(1, dataset.nTypes + 1);
        bestTrainingAccuracyAPN = zeros(1, dataset.nTypes + 1);
        
        bestTestAccuracyNDCG = zeros(1, dataset.nTypes + 1);
        bestTestAccuracyAPOneThird = zeros(1, dataset.nTypes + 1);
        bestTestAccuracyAPTwenty = zeros(1, dataset.nTypes + 1);
        bestTestAccuracyAPN = zeros(1, dataset.nTypes + 1);
        
        % execute the algorithm for nRuns times    
        for run = 1 : nRuns
            if algorithm == 1
                [gamma, trainingAccuracyNDCG, trainingAccuracyAPOneThird, trainingAccuracyAPTwenty, trainingAccuracyAPN,  r] = estimateAuthorityPropagationFactorRankSVM(dataset.groundTruthPartialRankCell{experiment}, dataset.nTypes, nIteration, 0.001, dataset, K, isNonnegative, resultDir, experiment);
            elseif algorithm == 2
                if cvx == 0
                    if checkConvergence == 0
                        [gamma, trainingAccuracyNDCG, trainingAccuracyAPOneThird, trainingAccuracyAPTwenty, trainingAccuracyAPN, r, runIteration] = estimateAuthorityPropagationFactorGD(dataset, dataset.groundTruthPartialRankCell{experiment}, nIteration, K, 'AP', 0.001, isNonnegative, isLocalGD, equation);
                    else 
                        [gamma, trainingAccuracyNDCG, trainingAccuracyAPOneThird, trainingAccuracyAPTwenty, r] = estimateAuthorityPropagationFactorGDConvergenceCheck(dataset, dataset.groundTruthPartialRankCell{experiment}, nIteration, K, 'AP', 0.001, isNonnegative, isLocalGD, equation);
                    end
                else
                        [gamma, trainingAccuracyNDCG, trainingAccuracyAPOneThird, trainingAccuracyAPTwenty, r, runIteration] = estimateAuthorityPropagationFactorGDCVX(dataset, dataset.groundTruthPartialRankCell{experiment}, nIteration, K, 'AP', 0.001, isNonnegative, isLocalGD, equation);
                end
            end
            
            % collect training accuracy for each iteration to calculate
            % variance
            expTrainingAccuracyAllNDCG(counter, :) = trainingAccuracyNDCG;
            expTrainingAccuracyAllAPOneThird(counter, :) = trainingAccuracyAPOneThird;
            expTrainingAccuracyAllAPTwenty(counter, :) = trainingAccuracyAPTwenty;
            expTrainingAccuracyAllAPN(counter, :) = trainingAccuracyAPN;
            
            testAccuracyNDCG = computeAccuracy('NDCG', dataset.groundTruthRankingCell{experiment}, r, '');
            testAccuracyAPOneThird = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, r, '1/3');
            testAccuracyAPTwenty = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, r, '20');
            testAccuracyAPN = computeAccuracy('AP', dataset.groundTruthRankingCell{experiment}, r, 'N');
            
            expTestAccuracyAPAllAPOneThird(counter, :) = testAccuracyAPOneThird;
            expTestAccuracyAPAllAPTwenty(counter, :) = testAccuracyAPTwenty;
            expTestAccuracyAllNDCG(counter, :) = testAccuracyNDCG;
            expTestAccuracyAPAllAPN(counter, :) = testAccuracyAPN;
            
            if algorithm == 2
                expConvergenceInfo(counter, :) = runIteration;
            end
            
            counter = counter + 1;
            
            if trainingAccuracyAPOneThird(dataset.nTypes + 1) - bestTrainingAccuracyAPOneThird(dataset.nTypes + 1) > 0
                bestGamma = gamma;
                bestR = r;
                
                bestTrainingAccuracyNDCG = trainingAccuracyNDCG;
                bestTrainingAccuracyAPOneThird = trainingAccuracyAPOneThird;
                bestTrainingAccuracyAPTwenty = trainingAccuracyAPTwenty;
                bestTrainingAccuracyAPN = trainingAccuracyAPN;
                
                bestTestAccuracyAPOneThird = testAccuracyAPOneThird;
                bestTestAccuracyNDCG = testAccuracyNDCG;
                bestTestAccuracyAPTwenty = testAccuracyAPTwenty;
                bestTestAccuracyAPN = testAccuracyAPN;
            end
        end
        counter = counter + 1;
        
        expBestGamma{experiment} = bestGamma;

        expBestR{experiment} = bestR;
        
        expTestAccuracyNDCG(experiment, :) = bestTestAccuracyNDCG;
        expTestAccuracyAPOneThird(experiment, :) = bestTestAccuracyAPOneThird;
        expTestAccuracyAPTwenty(experiment, :) = bestTestAccuracyAPTwenty;
        expTestAccuracyAPN(experiment, :) = bestTestAccuracyAPN;
        
        expTrainingAccuracyNDCG(experiment, :) = bestTrainingAccuracyNDCG;
        expTrainingAccuracyAPOneThird(experiment, :) = bestTrainingAccuracyAPOneThird;
        expTrainingAccuracyAPTwenty(experiment, :) = bestTrainingAccuracyAPTwenty;
        expTrainingAccuracyAPN(experiment, :) = bestTrainingAccuracyAPN;
    end
    
    % Derive the file name
    algoName = '';
        
    if algorithm == 1
        algoName = 'SVM_';
    elseif algorithm == 2
        algoName = 'GD_';
        if equation == 1
            algoName = strcat(algoName, 'Eq1_');
        elseif equation == 2
            algoName = strcat(algoName, 'Eq2_');
        end
        if isLocalGD == 1
            algoName = strcat(algoName, 'Local_');
        else
            algoName = strcat(algoName, 'Global_');
        end
        if cvx == 1
            algoName = strcat(algoName, 'CVX_');
        end
    end

    if isNonnegative == 1
        algoName = strcat(algoName, 'NonNeg_');
    else
        algoName = strcat(algoName, 'NoConstraint_');
    end

    
    % write results to excel
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrNDCG.xlsx')),expTrainingAccuracyNDCG);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeNDCG.xlsx')),expTestAccuracyNDCG);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllNDCG.xlsx')),expTrainingAccuracyAllNDCG);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllNDCG.xlsx')),expTestAccuracyAllNDCG);

    
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAPOneThird.xlsx')),expTrainingAccuracyAPOneThird);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAPOneThird.xlsx')),expTestAccuracyAPOneThird);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllAPOneThird.xlsx')),expTrainingAccuracyAllAPOneThird);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllAPOneThird.xlsx')),expTestAccuracyAPAllAPOneThird);
    
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAPTwenty.xlsx')),expTrainingAccuracyAPTwenty);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAPTwenty.xlsx')),expTestAccuracyAPTwenty);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllAPTwenty.xlsx')),expTrainingAccuracyAllAPTwenty);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllAPTwenty.xlsx')),expTestAccuracyAPAllAPTwenty);
    
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAPN.xlsx')),expTrainingAccuracyAPN);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAPN.xlsx')),expTestAccuracyAPN);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTrAllAPN.xlsx')),expTrainingAccuracyAllAPN);
    xlswrite(fullfile(resultDir, strcat(algoName, 'bestTeAllAPN.xlsx')),expTestAccuracyAPAllAPN);
    
    
    if algorithm == 2
       xlswrite(fullfile(resultDir, strcat(algoName, 'ConvergenceInfo.xlsx')), expConvergenceInfo);
    end

    for experiment = 1 : dataset.nExpPerGroup
        xlswrite(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestGamma.xlsx')),expBestGamma{experiment});
        xlswrite(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestR.xlsx')),expBestR{experiment});
        saveRanking(fullfile(resultDir, strcat(algoName, 'exp',int2str(experiment), '_', 'BestRCell.xlsx')), GeneratePartialRanking(expBestR{experiment}, dataset.Type, dataset.nNodes, dataset.nTypes, 1, 1), dataset.nNodes, dataset.nTypes);
    end
%     if cvx == 1
%         matlabpool CLOSE
%     end
    toc(tStart) 
end

