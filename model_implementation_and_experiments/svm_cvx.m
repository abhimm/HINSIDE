function [ w ]= svm_cvx(x, y, C, nonnegativity)
%%%%% Inputs:
%%%%% x is of size n * m where m is # of types and n is # of instances
%%%%% y is of size n * 1 
%%%%% C and nonnegativity are scalars
%%%%% Output:
%%%%% w is of size m * 1

%%%%% This function runs SVM using CVX package and reports the obtained
%%%%% weights

    n = size(x,1);
    m = size(x,2);

    if nonnegativity > 0
        cvx_begin quiet
            variables w(m) e(n);
            minimize (w' * w + C*sum(e))
            subject to     
                e >= 0;
                w >= 0;
                y.*(x*w ) >= 1-e;
        cvx_end
    else
        cvx_begin quiet
            variables w(m) e(n);
            minimize (w' * w + C*sum(e))
            subject to     
                e >= 0;
                y.*(x*w ) >= 1-e;
        cvx_end
    end
end