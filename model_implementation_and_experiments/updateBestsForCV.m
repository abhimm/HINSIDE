function [bestNdcgTr, bestNdcgTe, bestMapTr, bestMapTe, bestGama] = updateBestsForCV(ndcgTr, ndcgTe, mapTr, mapTe, outputGama, experimentNumber,    list,  bestNdcgTr, bestNdcgTe, bestMapTr, bestMapTe, bestGama)
%%%%% This function's porpuse is to add or update the best acquired MAPs
%%%%% and NDCGs for each of the algorithms. ?This function is specificly
%%%%% for cross validation code.

    for iteration = 1: size(list,2)
        i = list(iteration);
        bestNdcgTr{i}(experimentNumber,:) = ndcgTr(i,:); 
        bestNdcgTe{i}(experimentNumber,:) = ndcgTe(i,:); 
        bestMapTr{i}(experimentNumber,:) = mapTr(i,:); 
        bestMapTe{i}(experimentNumber,:) = mapTe(i,:); 
        bestGama{i}{experimentNumber} = outputGama{i};
    end
end
