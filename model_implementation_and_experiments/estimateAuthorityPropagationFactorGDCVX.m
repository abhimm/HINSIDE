 function [ bestGamma, bestTrainingAccuracyNDCG, bestTrainingAccuracyAPOneThird, bestTrainingAccuracyAPTwenty, bestR, totalIteration ] = estimateAuthorityPropagationFactorGDCVX( dataset, partialRankCell, nIteration, K, accuracyMeasure, threshold, isNonNegative, isLocalGD, equation )
%This function computes authority propagation factor(gamma) using Gradient Descent.
% Input:
% partialRankList - partial rank list which serves as ground truth duging
%   gamma estimation.
% nIteration - number of iteration of RankSVM
% thershold - stopping criterion based on change in derivativ during
% successive iterations.
% dataset - a struct containg information of dataset
% objectiveFunction - objective function used to update the Gamma during
%   execution. Refers to eqn 37 and eqn 39 in draft.
% Accuracy Measure- AP, NDCG, MAP
% isNonNegative - define if non-negativity constraint has to be followed
% isLocalGD - if gradient descent is done at every step locally
% equation- equation to use for determining the derivative

% Output:
% bestGamma - authority propagation factor, a m x m matrix where m is no. of
%             types.
% bestTrainingAccuracy - best training accuracy calculated with respect to
%                        bestGamma
% bestR - best ranking corresponding to bestGamma.
    
    tStart = tic;
    % initialize gamma
    newGamma = rand(dataset.nTypes);

    % get the rank score using newGamma and update the best scores
    r = powerIteration( newGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P); 
    
    bestGamma = newGamma;
    bestR = r;
    bestTrainingAccuracyNDCG = computeAccuracy('NDCG', partialRankCell, bestR, '');
    bestTrainingAccuracyAPOneThird = computeAccuracy('AP', partialRankCell, bestR, '1/3');
    bestTrainingAccuracyAPTwenty = computeAccuracy('AP', partialRankCell, bestR, '20');
    
    
    % get data for K-fold cross-validation
    kCrossValidationFolds = generateCrossValidationFolds(K, partialRankCell);
    
    % generate training data and cross-validation training data
    trainingDataCV = cell(K, dataset.nTypes);
    trainingData = cell(1, dataset.nTypes);
    
    for type = 1 : dataset.nTypes
        trainingData{type} = generateTrainingPairForGD(partialRankCell{type}{1}, equation);
        for fold = 1 : K
            trainingDataCV{fold, type} = generateTrainingPairForGD(kCrossValidationFolds{fold, type}{1}, equation);
        end
    end    
    
    
    % penalty
    C = [100 10 1 0.1 0.001];
    
    
    % Run the algorithm nIteration times
    isGlobalIterationConverged = 0;
    
    for iteration = 1 : nIteration
        oldGamma = newGamma;
        % get the features using r
        features = computeFeatures(r, dataset.M, dataset.P, dataset.Type, dataset.T);
        % solve for every type
        parfor type = 1 : dataset.nTypes
            % set initial value for the iteration
            estimatedTypeSpecificGamma = oldGamma(:, type);

            tStartTrain = tic;
            estimatedTypeSpecificGamma = GradientDescentWithCVX(features, trainingData{type}, equation, isNonNegative)
            tTrain = toc(tStartTrain);
            
            fprintf('Iteration - %f, Training: Type - %f, Time - %f\n', iteration, type, tTrain);
            
            % if NAN entries are present, initialize it randomly
            if(sum(isnan(estimatedTypeSpecificGamma)) > 0)
                fprintf('Estimated gamma contains NAN entries')
                continue;
            end
            
            if(sum(isinf(estimatedTypeSpecificGamma)) > 0)
                fprintf('Estimated gamma contains inf entries')
                continue;
            end
            newGamma(:, type) = estimatedTypeSpecificGamma;
        end
%         newGamma
        % get the ranking based on new Gamma
        r = powerIteration( newGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);
        
        % get training accuracy
        trainingAccuracyAPOneThird = computeAccuracy('AP', partialRankCell, r, '1/3');
        
        if trainingAccuracyAPOneThird(dataset.nTypes + 1) - bestTrainingAccuracyAPOneThird(dataset.nTypes + 1) > 0
            bestTrainingAccuracyAPOneThird = trainingAccuracyAPOneThird;
            bestTrainingAccuracyNDCG = computeAccuracy('NDCG', partialRankCell, r, '');
            bestTrainingAccuracyAPTwenty = computeAccuracy('AP', partialRankCell, r, '20');
            bestGamma = newGamma;
            bestR = r;
        end
        
        if  norm(oldGamma - newGamma, 'fro') <= threshold
            isGlobalIterationConverged = 1;
            break
        end
        fprintf('iteration completed - %f\n', iteration);
    end

    fprintf('global iteration convergance - %f\n', isGlobalIterationConverged)
    totalIteration = iteration;
    toc(tStart) 
end

