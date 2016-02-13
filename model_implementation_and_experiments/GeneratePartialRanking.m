function [partialsCell, totalNumOfRankings] = GeneratePartialRanking(r, Type, n, m, p, numOfPartialRankings)
%%%%% Inputs:
%%%%% r is of size 1 * n
%%%%% p is a scaler represents a probability
%%%%% numOfPartialRankings is better to be 1, because in some functions
%%%%% values greather than 1 are not supported.
%%%%% Outputs:
%%%%% partialsCell is a cell array of size numOfPartialRankings * m

%%%%% This function gets a total ranking of n elements (with different
%%%%% node-types) and for each type it produces totalNumOfRankings partial
%%%%% rankings, where the size of partial rankings are determined by value
%%%%% of p

    partialsCell = cell(1,m);
    
    list = [(1:n).'  r];
    
    %%%%% for each node-type 
    for i = 1: m
        partialsCell{i} = cell(1,numOfPartialRankings);
        typeSpecificList = list((Type(list(:,1))==i),:);  
            
        for j =1:numOfPartialRankings
            
            %%%%% manually set minimumSizeOfPartialRankings in order to not
            %%%%% having very small partial rankings.
            minimumSizeOfPartialRankings = 4;
            selectionSize= max( minimumSizeOfPartialRankings, ceil(p*size(typeSpecificList,1)) );
            
            %%%%% randomely select indices of some nodes of type i in order
            %%%%% to put them in the partial ranking
            selectedIndices = selectRandom( (1:size(typeSpecificList,1)).' , selectionSize  );
        
            partialsCell{i}{j} = typeSpecificList(selectedIndices,:);
        
        end
        
    end

    %%%%% Calculate totalNumOfRankings 
    %%%%% totalNumOfRankings represents the no of nodes whose ranking is
    %%%%% present in the ranking cell
    totalNumOfRankings = 0;
    for i = 1: m
        for j = 1: numOfPartialRankings
            totalNumOfRankings = totalNumOfRankings + (size(partialsCell{i}{j},1)>0);
        end
    end
    
end