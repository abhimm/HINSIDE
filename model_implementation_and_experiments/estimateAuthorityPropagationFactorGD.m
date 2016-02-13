 function [ bestGamma, bestTrainingAccuracyNDCG, bestTrainingAccuracyAPOneThird, bestTrainingAccuracyAPTwenty, bestTrainingAccuracyAPN, bestR, totalIteration ] = estimateAuthorityPropagationFactorGD( dataset, partialRankCell, nIteration, K, accuracyMeasure, threshold, isNonNegative, isLocalGD, equation )
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
    bestTrainingAccuracyAPN = computeAccuracy('AP', partialRankCell, bestR, 'N');
    
    
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
        
        derivativeTypeBased = zeros(dataset.nTypes);
        
        % solve for every type
        for type = 1 : dataset.nTypes
            % set initial value for the iteration
            estimatedTypeSpecificGamma = oldGamma(:, type);
            tempGamma = oldGamma;
            % set no of iteration 
            nLocalIteration = 1;
            % if Gradient descent has to be performed in every iteration,
            % instead of a global gradient descent, set no of iteration got
            % local gradient descent.
            if isLocalGD == 1
                nLocalIteration = nIteration; 
            end
            isLocalIterationConverged = 0;
            for localIteration = 1 : nLocalIteration 
                derivative = zeros(dataset.nTypes, 1);

                if equation == 2
                    % Learn the gamma over the complete training dataset for the
                    % given type
                    derivative = GradientDescent(features, trainingData{type}, estimatedTypeSpecificGamma, 0, equation);
                elseif equation == 1
                % first equation usage doesn't require any cross validation
                    derivative = GradientDescent(features, trainingData{type}, estimatedTypeSpecificGamma, 0, equation); % Here bestC is redundant
                end
%                 fprintf('type - %f', type);
%                 derivative
                
                stepSize = 1/ (size(trainingData{type}, 1)*sqrt(iteration + 1)); 
                
                if isLocalGD == 1
                    stepSize = 1/ (size(trainingData{type}, 1)*sqrt(localIteration + 1)); 
                end
                
                if type == 1 || type == 4
                    %stepSize = stepSize/1000;
                    stepSize = stepSize/10;
                end
                estimatedTypeSpecificGamma = estimatedTypeSpecificGamma - stepSize*derivative;

                % introduce non-negativity constraint if required
                if isNonNegative == 1 
                    estimatedTypeSpecificGamma(estimatedTypeSpecificGamma < 0) = 0;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 fprintf('Type - %f\n', type)
%                 fprintf('estimated type specific gamma\n')
%                 estimatedTypeSpecificGamma
%                 fprintf('stepSize*derivative\n')
%                 stepSize*derivative
%                 fprintf('localIteration - %f\n', localIteration)
                %pause(3)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % if NAN entries are present, leave current values as it is
                if(sum(isnan(estimatedTypeSpecificGamma)) > 0)
                    fprintf('Estimated gamma contains NAN entries\n')
                    continue
                end

                if(sum(isinf(estimatedTypeSpecificGamma)) > 0)
                    fprintf('Estimated gamma contains inf entries\n')
                    continue
                end
                            
                if norm(derivative, 1) < threshold
                    isLocalIterationConverged = 1;
                    break
                end
            end
            
            fprintf('Type - %f\n', type)
            fprintf('local iteration convergance: localIteration - %f, result - %f\n', localIteration, isLocalIterationConverged)
            
%             fprintf('Type - %f', type)
%             estimatedTypeSpecificGamma
            newGamma(:, type) = estimatedTypeSpecificGamma;
            derivativeTypeBased(:, type) = derivative;
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
            bestTrainingAccuracyAPN = computeAccuracy('AP', partialRankCell, r, 'N');
            
            bestGamma = newGamma;
            bestR = r;
        end
        
        if (isLocalGD == 0 &&  norm(derivativeTypeBased, 'fro') <= threshold) || norm(oldGamma - newGamma, 'fro') <= 0.01
            isGlobalIterationConverged = 1;
            break
        end
        fprintf('iteration completed - %f\n', iteration);
    end
    fprintf('global iteration convergance - %f\n', isGlobalIterationConverged)
    totalIteration = iteration;
    toc(tStart) 
end

