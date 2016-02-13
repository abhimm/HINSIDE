function F = computeFeatures(R,M,P,Type,T)
%%%%% Inputs: 
%%%%% F is of size m * n
%%%%% R is of size n * 1
%%%%% M is of size n * n
%%%%% P is of size n * n
%%%%% Type is of size n * 1
%%%%% T is of size n * m
%%%%% Output:
%%%%% F is of size n * m 

%%%%% This function produces feature matrix that is introduced in eq. 28 of
%%%%% the draft. 
    %{
    Correct
    m = max(Type);
    n = size(M,1);
    F = zeros(m,n);
    
    for t=1:m
        type = t;
        for i = 1:n
            s2 = 0;
            for j =1:n
                s1 = 0;
                if( Type(j) == t)
                    for k = 1:n
                        if( Type(k) == Type(i) && i~= k)
                            s1 = s1 + P(k,j) * R(k);
                        end
                    end
                    s1 = s1 + R(j);
                        s2 = s2 +  M(j,i) * s1;
                end
                b(t,j) = s1;
            end
            F(t,i) = s2;
        end
    end
    %}
    
    %{
    Incorrect 
    m = max(Type);
    n = size(M,1);

    r1 =  (R*ones(1,m) .* T);
    a = P.' * r1;
    a1 = R * ones(1,m) + a;
    a2 = a1 .* T;
    F = a2' * M;
    %}
    
    nType = max(Type);
    nNodes = size(Type, 2);
    
    F = zeros(nType,nNodes);

    r1 =  (R*ones(1,nType) .* T);
    a = P.' * r1;
    a1 = R * ones(1,nType) + a;
    
    for type = 1: nType
        typeWiseScores = a1.' .* repmat(T(:,type).', nType, 1) ;

        for node = 1 : nNodes
            F(type, node) = (typeWiseScores(Type(node),:) -  R(node)*(T(:, type) .* P(:, node)).') * M(:, node);
        end    
    end
    if (sum(isinf(F)) > 0)
        fprintf('Features contain Inf entries')
    end
    
    if (sum(isnan(F)) > 0)
        fprintf('Features contain Nan entries')
    end
end

        
