function [preferences , partialsCell, totalNumOfRankings] = GeneratePreferences (r, Type, m, prob, dataset, numOfPartialRankings , trainingCell)
%%%%% Input:
%%%%% trainingCell is a cell array of size 1 * m
%%%%% Outputs:
%%%%% preferences is a cell array of size 1 * m
%%%%% partialsCell is a cell array of size numOfPartialRankings * m

%%%%% This function produces partial rankings required to be used as
%%%%% training data. It also makes it in formats that can be easily used as
%%%%% training data for SVM. preferences is is in the format that is
%%%%% required for CVX package.
    
    %% Generate Partial Rankings
    n = size(r,1);
    %%%%% if size of trainingCell greater than 1, it means this function
    %%%%% has been called for cross-validation porpuse.
    if size(trainingCell,2)==m
        [partialsCell, totalNumOfRankings] = GeneratePartialRankingForCV(r,Type,n,m,prob, numOfPartialRankings, trainingCell);
    else
        [partialsCell, totalNumOfRankings] = GeneratePartialRanking(r,Type,n,m,prob, numOfPartialRankings);
        
    end
    partialsCell
    %%%%% Generate preferences in order to be used as input to SVM
    preferences = cell(1,m);
    for i = 1:m
        
        %%%%% counting the totall number of pair-wise comparisons for each
        %%%%% node-type
        partialRankingSize = 0;
        for ii = 1:numOfPartialRankings
            sizeP = size(partialsCell{i}{ii},1);
            partialRankingSize =  partialRankingSize + sizeP * (sizeP-1)/2;
        end
        
        %%%%% this is working only for one partial ranking per node-type
        for ii = 1:numOfPartialRankings
            partial = partialsCell{i}{ii}(:,1);
            prefs3 = nchoosek(partial,2);
            prefs3 = [ prefs3; prefs3(:,[2,1])];
            [~ , labels]  = ismember(prefs3, partial, 'R2012a');
            prefs3 = [ prefs3 sign(labels(:,2) - labels(:,1))];
            
        end
        
        TypeIndices = find(Type==i);
        [ ~, prefs3(:,1)]  = ismember(prefs3(:,1),TypeIndices,'R2012a');
        [ ~, prefs3(:,2)]  = ismember(prefs3(:,2),TypeIndices,'R2012a');
        
        preferences{i}=prefs3;
        
    end
    preferences
  
end
    
    