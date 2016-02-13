function [ bestGamma, bestTrainingAccuracyNDCG, bestTrainingAccuracyAPOneThird, bestTrainingAccuracyAPTwenty, bestTrainingAccuracyAPN, bestR  ] = estimateAuthorityPropagationFactorRankSVM( partialRankCell, nTypes, nIteration, threshold, dataset, K, isNonnegative, resultDir, expNo)
%This function computes authority propagation factor(gamma) using Rank SVM.
% Input:
% partialRankList - partial rank list which serves as ground truth duging
% gamma estimation.
% nType - number of types of nodes
% nIteration - number of iteration of RankSVM
% thershold - stopping criterion based on change in gamma value during
% successive iterations.
% dataset - a struct containg information of dataset
%
% Output:
% bestGamma - authority propagation factor, a m x m matrix where m is no. of
%             types.
% bestTrainingAccuracy - best training accuracy calculated with respect to
%                        bestGamma
% bestR - best ranking corresponding to bestGamma.
    tStart = tic;
    fileID = fopen(fullfile(resultDir, strcat(num2str(expNo), '_', 'ConvexSolverTimerLog.txt')),'a');
    % initialize gamma
    newGamma = rand(nTypes);
  
    r = powerIteration( newGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);    
   
    % initialize ranking scores for all nodes and best results
    bestR = r;
    bestTrainingAccuracyNDCG = computeAccuracy('NDCG', partialRankCell, bestR, '');
    bestTrainingAccuracyAPOneThird = computeAccuracy('AP', partialRankCell, bestR, '1/3');
    bestTrainingAccuracyAPTwenty = computeAccuracy('AP', partialRankCell, bestR, '20');
    bestTrainingAccuracyAPN = computeAccuracy('AP', partialRankCell, bestR, 'N');    
    bestGamma = newGamma;
    
    % get data for K-fold cross-validation
    kCrossValidationFolds = generateCrossValidationFolds(K, partialRankCell);
    
    % slack penalty
    C = [100 10 1 0.1 0.001];

    % epsilon to handle NAN entry case during parameter estimation 
    epsilon = 0.001;
    
    
    % Run the algorithm nIteration times
    for iteration = 1 : nIteration
        oldGamma = newGamma;
        % get the features using r
        features = computeFeatures(r, dataset.M, dataset.P, dataset.Type, dataset.T);
        
        % estimate new Gamma for every type of node
        for type = 1 : nTypes
            bestC = C(1);
            bestVaildationAccuracy = 0;
            
            for c = 1 : size(C,2)
                validationAccuracy = 0;
                for fold = 1 : K
                    trainingDataCV = generateTrainingPairs(kCrossValidationFolds{fold,type}{1});
                    tempGamma = oldGamma;
                    
                    tStartCV = tic;
                    estimatedTypeSpecificGammaCV = SVM_(features, trainingDataCV, C(c), isNonnegative);
                    tCV = toc(tStartCV);
                    fprintf(fileID, 'Iteration - %f, Cross validation: Type - %f, CV fold - %f, Time - %f\n', iteration, type, c, tCV);
                    
                    % if NAN entries are present, continue
                    if(sum(isnan(estimatedTypeSpecificGammaCV)) > 0)
                        fprintf('Estimated gamma contains NAN entries, C - %f', C(c))
                        continue
                    end
                    if(sum(isinf(estimatedTypeSpecificGammaCV)) > 0)
                        fprintf('Estimated gamma contains inf entries, C - %f', C(c))
                        continue
                    end
                    
                    % impose non-negativity constraint, if requested
                    if isNonnegative > 0
                        estimatedTypeSpecificGammaCV(estimatedTypeSpecificGammaCV<0) = 0;
                    end
                                        
                    % update the type specific column in old gamma with new found Gamma for current type
                    tempGamma(:,type) = estimatedTypeSpecificGammaCV;
                    
                    % get new ranking based on newly found gamma
                    rTemp = powerIteration(tempGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);
                    
                    % get the validation set accuracy
                    %validationAccuracy  = validationAccuracy + computeRankScoreBasedNDCG(kCrossValidationFolds{fold, type}{2}, rTemp);
                    validationAccuracy = validationAccuracy + computeRankScoreBasedAP(kCrossValidationFolds{fold, type}{2}, rTemp, uint32(0.33*size(kCrossValidationFolds{fold, type}{2}, 1)));
                end
                
                validationAccuracy = validationAccuracy/K;
                
                % update the best slack penalty parametr and best
                % validation accuracy
                if bestVaildationAccuracy < validationAccuracy
                    bestC = C(c);
                    bestVaildationAccuracy = validationAccuracy;
                end
            end
            
            % Learn the gamma over the complete training dataset for the
            % given type
            trainingData = generateTrainingPairs(partialRankCell{type}{1});
            
            tStartTrain = tic;
            estimatedTypeSpecificGamma = SVM_(features, trainingData, bestC, isNonnegative);
            tTrain = toc(tStartTrain);
            fprintf(fileID, 'Iteration - %f, Training: Type - %f, Time - %f\n', iteration, type, tTrain);
            
            % if NAN entries are present, initialize it randomly
            if(sum(isnan(estimatedTypeSpecificGamma)) > 0)
                fprintf('Estimated gamma contains NAN entries, bestC - %f', bestC)
                continue;
            end
            
            if(sum(isinf(estimatedTypeSpecificGamma)) > 0)
                fprintf('Estimated gamma contains inf entries, bestC - %f', bestC)
                continue;
            end
 
            % impose non-negativity constraint, if requested
            if isNonnegative > 0
                estimatedTypeSpecificGamma(estimatedTypeSpecificGamma < 0) = 0;
            end
            
            % update the column corresponding to the present type in newGamma    
            newGamma(:, type) = estimatedTypeSpecificGamma;    
        end
        
        % get new ranking based on new gamma
        r = powerIteration( newGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);
        
        %get training accuracy
        trainingAccuracyAPOneThird = computeAccuracy('AP', partialRankCell, r, '1/3');
        
        if trainingAccuracyAPOneThird(nTypes + 1) - bestTrainingAccuracyAPOneThird(nTypes + 1) > 0
            bestTrainingAccuracyAPOneThird = trainingAccuracyAPOneThird;
            bestTrainingAccuracyNDCG = computeAccuracy('NDCG', partialRankCell, r);
            bestTrainingAccuracyAPTwenty = computeAccuracy('AP', partialRankCell, r, '20');
            bestTrainingAccuracyAPN = computeAccuracy('AP', partialRankCell, r, 'N');
            bestGamma = newGamma;
            bestR = r;
        end
        
        if norm(newGamma - oldGamma, 'fro') < threshold
            break
        end
    end
    fclose(fileID);
    toc(tStart)
end

