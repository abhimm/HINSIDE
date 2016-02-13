function [realGamma, r, realRankingCell] = initExperiment(dataset, experiment, n, m, M, T, Type, E, P)
%%%%% This function is Doing initialization steps required for each
%%%%% experiment including assigning realGamma and generating realRanking

        %%%%% initialize realGamma or load it from file and then save it to
        %%%%% file
        realGamma=inversePL(m);
        %realGamma =csvread(fullfile(dataset,'realGamma','output',strcat('realGamma_',num2str(experiment)),'.csv'));
        xlswrite(fullfile(dataset,'output',strcat('realGamma_',num2str(experiment),'.xlsx')),realGamma);
        
        %%%%% GENERATE INITIAL RANKING AND SAVE IT INTO FILE
        r = rand(n,1);	 
        initialRankingCell = GeneratePartialRanking(r, Type, n, m, 1, 1) ;
        saveRanking(fullfile(dataset,'output',strcat('realInitialRanking_',num2str(experiment),'.xlsx')),initialRankingCell,n,m);

        %%%%% GENERATE REAL RANKING
        r = powerIteration( realGamma,n, M, T, E, P);
        realRankingCell = GeneratePartialRanking(r, Type, n, m, 1, 1);
        saveRanking(fullfile(dataset,'output',strcat('realRanking_',num2str(experiment),'.xlsx')),realRankingCell,n,m);
        
end