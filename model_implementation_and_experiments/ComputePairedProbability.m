function  [pairedProb, pairedComparison] = ComputePairedProbability(rankingCell )
%%%%% Input:
%%%%% rankingCell is a cell array of size 1 * m and each element is an
%%%%% array of size ranking_size * 2 . 
%%%%% Outputs:
%%%%% pairedProb and pairedComparison are cell arrays of size 1 * m

%%%%% This function only works for the case that numOfPartialRankings is 1.
%%%%% It gets m number of rankings ( one for each node-type ) and for each
%%%%% node-type (t) it produces two square matrices. In pairedProb, element
%%%%% at row i and col j represents how likely rank i greater than rank j
%%%%% is, where i and j are showing the i_th and the j_th nodes of type t.
%%%%% In pairedComparison, element at row i and col j represents if i
%%%%% should be ranked ahead of j or not, with values of 1 and 0.
    
    m = size(rankingCell,2);
    pairedProb=cell(1,m);
    pairedComparison=cell(1,m);
    
    %%%%% for each node-type m
    for i = 1:m
        temp=rankingCell{i}{1};
        temp=sortrows(temp,1);
        r=temp(:,2);
        r = r / norm(r,'fro');
        R1=r*(ones(size(r)).');
        R2=ones(size(r))*(r.');
        O=R1-R2;   %%%%% O_{ij} = f(i,j) = r_i - r_j
        pairedProb{i} = exp(O)./(1+exp(O));
        pairedComparison{i} = ceil(O);
    end

end
