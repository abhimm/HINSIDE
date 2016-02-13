function [ w ] = SVM_(x, preferences, C , nonnegativity)
%%%%% Inputs:
%%%%% x is of size m * n where m is # of types and n is # of instances
%%%%% preferences is of size k * 3 where k is the number of paired
%%%%% instances
%%%%% C and nonnegativity are scalars
%%%%% Output:
%%%%% w is of size m * 1

%%%%% This function prepares the dataset in order to be used by svm_cvx
%%%%% function and finally returns the acquired weights as w.
    xx = x(:,preferences(:,1)) - x(:,preferences(:,2));
    if (sum(isinf(xx)) > 0)
        fprintf('In SVM_ :Features contain Inf entries')
    end
    
    if (sum(isnan(xx)) > 0)
        fprintf('In SVM_ : Features contain Nan entries')
    end
    yy = preferences(:,3)';
    xx = xx.';
    yy = yy.';
    size(xx);
    size(yy);
    w=svm_cvx(xx,yy,C, nonnegativity);

end