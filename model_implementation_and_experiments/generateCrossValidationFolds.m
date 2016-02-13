function [ kCrossValidationFolds ] = generateCrossValidationFolds( K, rankList )
%   This function creates folds for k-fold cross validation
%   Input arguments:
%       K - number of folds in cross-validation
%       rankList - rankList from which cross-validation folds are generated
%                  It is partial rank list, a cell array of size 1 x no of
%                  types, containing partial rank list for corresponding
%                  type.
%   Output arguments:
%       kCrossValidationFolds - a cell array of size, k x m, containing
%       training set and validation set in each cell for corresponding
%       type.

    kCrossValidationFolds = cell(K, size(rankList, 2));
        
    % Loop for every type
    for type = 1 : size(rankList, 2)
        indices = crossvalind('Kfold', size(rankList{type}{1}, 1), K);
        for fold = 1 : K
            validationSetIndices = find(indices == fold);
            trainingSetIndices = setdiff( (1 : size(rankList{type}{1},1)).', validationSetIndices);
                        
            % prepare training and validation set
            kCrossValidationFolds{fold, type}{1} = rankList{type}{1}(trainingSetIndices, :);
            kCrossValidationFolds{fold, type}{2} = rankList{type}{1}(validationSetIndices, :);
        end
    end    
end

