function [ r ] = PageRank( A, beta, nIteration )
% This function computes page rank for given directed graph
%   A = adjecancy matrix
%   beta = damping factor
%   nIteration = no. of iterations in power iteration
%   r = ranking 
    nNodes = size(A, 1);
    
    outDegree = sum(A, 2);
    % get dead end nodes (sinks)
    deadEndNodes = (outDegree == 0);
    % make the out degree for sinks as 1
    outDegree(deadEndNodes) = 1;
    % initialize r
    rNew = ones(nNodes, 1) ./ nNodes;
    
    for i = 1:nIteration
        rOld = rNew;
        deadEndNodesScores = sum(rOld(deadEndNodes));
        rNew = (1 - beta)/nNodes + beta*( A' * (rOld./outDegree) + deadEndNodesScores/nNodes );
        if sum(abs(rNew - rOld)) < 0.001
            fprintf('converged\n')
            break
        end
    end
    r = rNew;

end

