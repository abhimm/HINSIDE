function [Gamma ] = inversePL(m, isDiagonalHeavy)
%%%%% Gamma is of size m * m

%%%%% This function gets m as the size of Gamma matrix (m * m) which
%%%%% needs to be initialized in a way that elements of each row of
%%%%% Gamma matrix need to be obtained by a power law function. Here we
%%%%% manually set the value of alpha as the parameter of the power law
%%%%% function to be 3.5 . 
    rng('shuffle')
    x = 0.1 : 0.05 : 10; %%%% a row vector with values ranging from 1 to 
                          %%%% 100 with difference of 0.00025 
    
    alpha = 1.2; %%%% Check standard value for alpha
    xMin = min(x);
    
    %%%%% Get the PDF of inverse power law
    inversePowerLawPDF = ((alpha-1) / xMin) * (x/xMin) .^ (-alpha);
    %%%%% Get the CDF of inverse power law numerically
    inversePowerLawCDF = cumsum(inversePowerLawPDF);
    %%%%% Normalize
    inversePowerLawCDF = inversePowerLawCDF / inversePowerLawCDF(end);
    %%%%% Generate numberOfRandoms uniformly distributed random numbers.
    numberOfRandoms = m*m;
    uniformlyDistributedRandomNumbers = rand(numberOfRandoms, 1);
    
    %%%%%-----------------------------------------------------------------
    %%%%% Invert the CDF of the Inverse Power Law function to get a
    %%%%% function that can generate random numbers drawn from a Inverse
    %%%%% Power Law distribution, given numbers drawn from a uniform distribution.
    inversePowerLawDistNumbers = zeros(length(uniformlyDistributedRandomNumbers), 1);
    for k = 1 : length(uniformlyDistributedRandomNumbers)
        nearestIndex = find(inversePowerLawCDF >= uniformlyDistributedRandomNumbers(k), 1, 'first');
        inversePowerLawDistNumbers(k) = x(nearestIndex);
    end
    %%%%%-----------------------------------------------------------------
    
    Gamma = zeros(m);
    
    if isDiagonalHeavy == 1
        inversePowerLawDistNumbers = sort(inversePowerLawDistNumbers);
    
        diagEntries = inversePowerLawDistNumbers(numberOfRandoms - m + 1: numberOfRandoms);
        nonDiagEntries = inversePowerLawDistNumbers(1 : numberOfRandoms - m );

        diagEntries = diagEntries(randperm(length(diagEntries)));
        nonDiagEntries = nonDiagEntries(randperm(length(nonDiagEntries)));
    end    
    
    
    
    diagCounter = 1;
    nonDiagCounter = 1;
    counter = 1;
    for i = 1 : m
        for j = 1 : m
            if isDiagonalHeavy == 1
                if i == j
                    Gamma(i,j) = diagEntries(diagCounter);
                    diagCounter = diagCounter + 1;
                else 
                    Gamma(i,j) = nonDiagEntries(nonDiagCounter);
                    nonDiagCounter = nonDiagCounter + 1;
                end
            else 
                Gamma(i,j) = inversePowerLawDistNumbers(counter);
                counter = counter + 1;
            end
        end
    end

    
    
end