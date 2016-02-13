 function [ bestGamma, bestTrainingAccuracyNDCG, bestTrainingAccuracyAPOneThird, bestTrainingAccuracyAPTwenty, bestR ] = estimateAuthorityPropagationFactorGDConvergenceCheck( dataset, partialRankCell, nIteration, K, accuracyMeasure, threshold, isNonNegative, isLocalGD, equation )
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
    tic;
    
    % Run the algorithm nIteration times
    isGlobalIterationConverged = 0;
    iteration = 0;
    while 1
        iteration = iteration + 1;
        
        oldGamma = newGamma;
        % get the features using r
        features = computeFeatures(r, dataset.M, dataset.P, dataset.Type, dataset.T);
        
        derivativeTypeBased = zeros(dataset.nTypes);
        
        % solve for every type
        for type = 1 : dataset.nTypes
            % set initial value for the iteration
            estimatedTypeSpecificGamma = oldGamma(:, type);
            tempGamma = oldGamma;

            % if Gradient descent has to be performed in every iteration,
            isLocalIterationConverged = 0;
            localIteration = 0;
            while isLocalGD == 1 || (isLocalGD == 0 && localIteration == 0)
                localIteration = localIteration + 1;
                derivative = zeros(dataset.nTypes, 1);

                if equation == 2
                % if second equation is followed then hyperparameter has to
                % be determined using cross-validation
                    bestC = C(1);
                    bestVaildationAccuracy = 0;

                    % perform cross validation to determine 
                    for i = 1 : size(C, 2)
                        validationAccuracy = 0;
                        for fold = 1 : K
                            % get the derivate or delta for gradient descent 
                            derivativeCV = GradientDescent(features, trainingDataCV{fold, type}, estimatedTypeSpecificGamma, C(i), equation);

                            % get the step size, if it is not local GD then
                            % based on outer loop, otherwise inner loop
                            stepSize = 1 / (size(trainingDataCV{fold, type}, 1)*sqrt(iteration + 1));
                            if isLocalGD == 1
                                stepSize = 1 / (size(trainingDataCV{fold, type}, 1)*sqrt(localIteration + 1));
                            end

                            % get the new type specific gamma
                            estimatedTypeSpecificGammaCV = estimatedTypeSpecificGamma - stepSize*derivativeCV;
                            % if non-negativity constraint is required, project
                            % the resultant gamma 
                            if(isNonNegative == 1)
                                estimatedTypeSpecificGammaCV(estimatedTypeSpecificGammaCV < 0) = 0;
                            end 

                            % if NAN entries are present, continue
                            if(sum(isnan(estimatedTypeSpecificGammaCV)) > 0)
                                fprintf('Estimated gamma CV contains NAN entries, C - %f \n', C(i))
                                continue
                            end

                            if(sum(isinf(estimatedTypeSpecificGammaCV)) > 0)
                                fprintf('Estimated gamma CV contains inf entries, C - %f \n', C(i))
                                continue
                            end

                            % update the type specific column in old gamma with new found Gamma for current type
                            tempGamma(:, type) = estimatedTypeSpecificGammaCV;

                            % get new ranking based on newly found gamma
                            rTemp = powerIteration(tempGamma, dataset.nNodes, dataset.M, dataset.T, dataset.E, dataset.P);

                            % get the validation set accuracy
                            if strcmp(accuracyMeasure, 'NDCG') == 1
                                validationAccuracy  = validationAccuracy + computeRankScoreBasedNDCG(kCrossValidationFolds{fold, type}{2}, rTemp);
                            elseif strcmp(accuracyMeasure, 'MAP') == 1

                            elseif strcmp(accuracyMeasure, 'AP') == 1
                                validationAccuracy  = validationAccuracy + computeRankScoreBasedAP(kCrossValidationFolds{fold, type}{2}, rTemp, uint32(0.33*size(kCrossValidationFolds{fold, type}{2}, 1)));
                            end
                        end
                        %fprintf('Type %f C %f end \n', type, C(i))
                        validationAccuracy = validationAccuracy/K;
                        % update the best slack penalty parametr and best
                        % validation accuracy
                        if bestVaildationAccuracy < validationAccuracy
                            %fprintf('bestC updated to %f\n', C(i))
                            bestC = C(i);
                            bestVaildationAccuracy = validationAccuracy;
                        end
                    end

                    % Learn the gamma over the complete training dataset for the
                    % given type
                    derivative = GradientDescent(features, trainingData{type}, estimatedTypeSpecificGamma, bestC, equation);
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
               
                estimatedTypeSpecificGamma = estimatedTypeSpecificGamma - stepSize*derivative;
                
                % introduce non-negativity constraint if required
                if isNonNegative == 1 
                    estimatedTypeSpecificGamma(estimatedTypeSpecificGamma < 0) = 0;
                end
                
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
                fprintf('Type - %f\n', type)
                fprintf('local iteration - %f\n', localIteration)
            end
            
            fprintf('Type - %f\n', type)
            fprintf('local iteration convergance - %f\n', isLocalIterationConverged)
            
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
            bestGamma = newGamma;
            bestR = r;
        end
        
        if (isLocalGD == 0 &&  norm(derivativeTypeBased, 'fro') <= threshold) || norm(oldGamma - newGamma, 'fro') <= threshold
            isGlobalIterationConverged = 1;
            break
        end
        fprintf('iteration completed - %f\n', iteration);
    end
    fprintf('global iteration convergance - %f\n', isGlobalIterationConverged)
    fprintf('No of global iteration - %f\n', iteration);
    toc 
end

