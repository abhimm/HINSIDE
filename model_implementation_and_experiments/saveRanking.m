function [] = saveRanking(filename, ranking , n , m)
%%%%% This function gets a ranking as a cell object along with a file
%%%%% name. The ranking cell may have multiple rankings for multiple
%%%%% node-types. So, this function seperates all these rankings and
%%%%% exports all of them into the especified file.
    
    sortedRanking = zeros(n,m);
    startingPoint = 1;
    
    %%%%% For each node-type
    for i = 1:m

        %%%%% For each ranking in a fixed node-type
        for j = 1:size(ranking{i},2)
            
            %%%%% Sort the ranking 
            a = sortrows(ranking{i}{j},-2);
            sortedRanking(1:size(a,1) ,startingPoint:startingPoint + size(a,2)-1) = a;
            startingPoint = startingPoint + size(a,2)+1;
        end
        startingPoint = startingPoint + 1;
            
    end
    xlswrite(filename,sortedRanking);
end
