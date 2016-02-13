function [ derivative ] = GradientDescent( features, trainingPair, gamma, C, equation )
%	This function computes the derivative vector by applying eqn 39 

    deltaFeatures = features(:, trainingPair(:, 1)) - features(:, trainingPair(:, 2));
    oij = gamma.' * deltaFeatures;
    oij = -1 * oij; 
    expOij = exp(oij);
    pij = 1 ./ (1 + expOij);
 
    if equation == 2
            pij = pij - 1;
    
        pij = repmat(pij, size(features, 1), 1);
        derivative = pij .* deltaFeatures;
        derivative = sum(derivative, 2);
        derivative = derivative + C*gamma;
    elseif equation == 1
        pijGroundTruth = trainingPair(:,3).';
        deltaPij = pij - pijGroundTruth;
        deltaPij = repmat(deltaPij, size(features, 1), 1);
        derivative = deltaPij .* deltaFeatures;
        derivative = sum(derivative, 2);
    end
 
end

