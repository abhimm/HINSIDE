function [partialsCell, totalNumOfRankings] = GeneratePartialRankingForCV(r, Type, n, m, p, numOfPartialRankings, trainingCell)
    
    partialsCell = cell(1,m);

    list = [(1:n).'  r];
    for i = 1: m
        partialsCell{i} = cell(1,numOfPartialRankings);
        typeSpecificList = trainingCell{i}{1}; %list((Type(list(:,1))==i),:);  
        
        for j =1:numOfPartialRankings

            minimumSizeOfPartialRankings = 4;
            selectionSize= max( minimumSizeOfPartialRankings, ceil(p*size(typeSpecificList,1)) );
            selectedIndices = selectRandom( (1:size(typeSpecificList,1)).' , selectionSize  );
        
            partialsCell{i}{j} = typeSpecificList(selectedIndices,:);
            
        end
        
    end
    
    totalNumOfRankings = 0;
    for i = 1: m
        for j = 1: numOfPartialRankings
            totalNumOfRankings = totalNumOfRankings + (size(partialsCell{i}{j},1)>0);
        end
    end
    
end