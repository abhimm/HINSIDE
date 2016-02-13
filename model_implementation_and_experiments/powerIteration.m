function r = powerIteration(Gamma, n, M, T, E, P)
%%%%% Inputs:
%%%%% Gamma is of size m * m
%%%%% A, M, D, E, P are of size n * n
%%%%% T is of size m * m
%%%%% Type is of size N * 1
%%%%% Output:
%%%%% R is of size n * 1

%%%%% This function is doing power method. In fact it finds the result of
%%%%% power method by getting the eigenvector of the largest eigenvalue.
   
    %%%%% combining Gama with Adjacency matrix 
    M = M .* ( T * Gamma * T.'); 
    

    L=(M.' + (( M.' *  P.') .* E ) );
    E2=E+eye(n);
    %L = L / sum(sum(L));
    
    opts.tol = 1e-3;
    [ r y ] =  eigs(L,1, 'lm', opts);
    %r = abs(r);
    r = r./sum(r);
    
    %{
    %%%%% INFINITE LOOP OF POWER ITERATION
    threshold = 0.000001;
    iter = 1;
    while iter>=1         
        oldR = R;
        R = L * R;
    
        %%%%% local normalization: normalizing in a way that sum of R for each type is 1 
        %Normalization = max(0.0001,E2*R);
        %R  = R ./ Normalization;
        
        %%%%% global normalization
        R = R / norm(R,'fro');
        
        %%%%% STOPPING CONDITION
        if( norm(R - oldR , 'fro') < threshold)
            iter
            break;
        end;
        iter = iter +1 ;

    end
    %}
    
end