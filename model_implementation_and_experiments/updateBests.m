function [bestOutputR,bestNdcgTr, bestNdcgTe, bestMapTr, bestMapTe, bestGama] = updateBests(outputR,ndcgTr, ndcgTe, mapTr, mapTe, outputGama, experimentNumber,numOfExperiments,probNumber, list, bestOutputR, bestNdcgTr, bestNdcgTe, bestMapTr, bestMapTe, bestGama)
%%%%% This function's porpuse is to add or update the best acquired MAPs
%%%%% and NDCGs for each of the algorithms.

    x=numOfExperiments+1;
    
    %%%%% For each of the algorithms that stated in the list parameter
    for iteration = 1: size(list,2)
        i = list(iteration);
        bestNdcgTr{i}((probNumber-1)*x+experimentNumber,:) = ndcgTr(i,:); 
        bestNdcgTe{i}((probNumber-1)*x+experimentNumber,:) = ndcgTe(i,:); 
        bestMapTr{i}((probNumber-1)*x+experimentNumber,:) = mapTr(i,:); 
        bestMapTe{i}((probNumber-1)*x+experimentNumber,:) = mapTe(i,:); 
        bestGama{i}{(probNumber-1)*x+experimentNumber} = outputGama{i};

        bestOutputR{i}(:,(probNumber-1)*x+experimentNumber) = outputR(:,i);
    end
end
