function experimentSetUpDBLP( dataset, expSetIndex, nExpGroup, nExpPerGroup, isGammaInputExternal, isDiagonalHeavy, trainingDataFraction)
% This function creates dataset from the graph.
    rng('shuffle')    
    load(fullfile(dataset,'distance.mat'));
    load(fullfile(dataset,'referral.mat'));
    load(fullfile(dataset,'Type.mat'));
    load(fullfile(dataset,'T.mat'));
    load(fullfile(dataset,'h_score.mat'))

    D = distance;

    A = referral;
       
    nTypes = max(Type); % Type is row vector
    nNodes = size(A,1); % A's size along dimension 1 i.e. no. of nodes 
    
    E = T * T.' - eye(nNodes); % E is nxn matrix which contains 1 in E(i,j) if
                          % type(i) = type(j) and i != j
    %%%%% build proximity effect. Now, we are considering threshold
    %%%%% function in order to take into account the proximity effect.
    Box = D < 20;
    P = Box  - eye(nNodes);
    
    F = log(D + 1);
    %A = log(A + 1); % preventing as it is already low
    D = log(D + 1);
    M = A .* F;
    
    expSetFolderName = strcat('ExperimentSet_', num2str(expSetIndex));
    fullfile(dataset, expSetFolderName)
    mkdir(fullfile(dataset, expSetFolderName));  
    
    for i = 1 : nExpGroup
        % create experiment group folder
        expGroupFolder = strcat('expGroup', num2str(i));
        mkdir(fullfile(dataset, expSetFolderName, expGroupFolder));
        
        gamma = cell(nExpPerGroup, 1);
        r = cell(nExpPerGroup, 1);
        rankingCell = cell(nExpPerGroup, 1);
        partialRankingCell = cell(nExpPerGroup, 1);
        for j = 1 : nExpPerGroup
            % get the Gamma
            tempGamma = zeros(nTypes);
            if isGammaInputExternal == 1
                for a = 1 : nTypes
                    for b = 1 : nTypes
                        tempGamma(a,b) = input(strcat('Enter gamma value for cell: [', int2str(a), ',',  int2str(b), ']  ' ));
                    end
                end  
                gamma{j} = tempGamma;
            else
                gamma{j} = inversePL(nTypes, isDiagonalHeavy);
            end
            % get the r
            %r{j} = powerIteration( gamma{j} , nNodes, M, T, E, P);
            r{j} = h_score.'/sum(h_score);
            % get the ranking cell
            rankingCell{j} = GeneratePartialRanking(r{j}, Type, nNodes, nTypes, 1, 1);
            
            % get the partial ranking cell with 40% data
            partialRankingCell{j} = GeneratePartialRanking(r{j}, Type, nNodes, nTypes, trainingDataFraction, 1);
            
            % save data to excel
            xlswrite(fullfile(dataset, expSetFolderName, expGroupFolder, strcat('exp_', int2str(j),'_groundTruthGamma.xlsx')), gamma{j});
            saveRanking(fullfile(dataset, expSetFolderName, expGroupFolder, strcat('exp_', int2str(j),'_groundTruthRankingCell.xlsx')),rankingCell{j}, nNodes, nTypes);
            saveRanking(fullfile(dataset, expSetFolderName, expGroupFolder, strcat('exp_', int2str(j),'_groundTruthPartialRankingCell.xlsx')),partialRankingCell{j}, nNodes, nTypes);
        end

        save(fullfile(dataset, expSetFolderName, expGroupFolder, 'expGroupData.mat'), 'r', 'gamma', 'rankingCell', 'partialRankingCell');
    end
    
    save(fullfile(dataset, expSetFolderName, 'experimentSetData.mat'), 'D', 'A', 'E', 'T', 'Type', 'P', 'M')
end

