function [ n , m, A, M, D, T, Type, E ,P ,Gamma] = simulationInput(  dataset )
%%%%% This function first loads the input matrices and then builds some
%%%%% secondary matrices that are needed for the Power Method.

    load(fullfile(dataset,'distance.mat'));
    load(fullfile(dataset,'referral.mat'));
    load(fullfile(dataset,'Type.mat'));
    load(fullfile(dataset,'T.mat'));
    
    
    D = distance;

    A = referral;
    %%%%% In order to decrease the effect of weight matrix, just un-comment
    %%%%% the following line
    %A = max(0,log2(A)+1)

    m = max(Type); % Type is row vector
    n = size(A,1); % A's size along dimension 1 i.e. no. of nodes 
    
    Gamma = inversePL(m); % gets Gamma matrix   
    E = T * T.' - eye(n); % E is nxn matrix which contains 1 in E(i,j) if
                          % type(i) = type(j) and i != j
                          
 
    
    %%%%% build proximity effect. Now, we are considering threshold
    %%%%% function in order to take into account the proximity effect.
    Box = D < 20;
    P = Box  - eye(n);

    
    %%%%% row normalizing A with respect to types of nodes. In fact, for each node (i) and for each type (t) we count the
    %%%%% number of out-going edges from i to a node of type t and then
    %%%%% divide the weight of such edges by their count.
    %{
    M = A;
    for i=1:n
         sumType = zeros(1,max(Type));
         for j=1:n
            sumType(Type(j)) = sumType(Type(j))+ (M(i,j)>0);
         end
         for j=1:n
            M(i,j) = M(i,j)/max(1,sumType(Type(j)));
         end
         
    end
    %}
   %The code below dividing each entry(i,j) in A with no. of neighbors i
   %has of type(j). 
   % A_ = A>0;
   % sumType = (max(1,A_*T)) * T';
   % M = A./sumType;
   % instead using a directly
    
    
    %%%%% combining Distance with Adjacency matrix as it is stated in the
    %%%%% draft. Here distance are sorted first then their index in the
    %%%%% sorted list is chosen to represent the distance.
    %{
    F = zeros(n,n);
    for i=1:n
         for j=1:n
             %F(i,j) = sum(sum( D < D(i,j) ))+1;
             F(i,j) = find(D1n2Sorted == D(i,j),1);
         end
    end
    %}
    F = zeros(n,n);
    %D_ = reshape(D,1,n^2);
    %D_Sorted_  = sort(D_);
    %[~,F] = ismember(D,D_Sorted_,'R2012a');
    %%%% Take the logrithm of distance instead of taking correspoding
    %%%% sorted index
    F = log10(D + 1);
    M = A .* F;
    
end
    
    
    