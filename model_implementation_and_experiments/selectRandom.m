
function [selection] = selectRandom(values, selectionSize)
%%%%% Inputs:
%%%%% values is a vertical array
%%%%% selectionSize is a scalar
%%%%% Output:
%%%%% selection is a vertical array

%%%%% This function randomely chooses selectionSize number of elements in
%%%%% values array. 

    selection = zeros(1, selectionSize);
    for i = 1:selectionSize
        r = values( ceil( rand()*(size(values,1)) ) );
        values = values(values ~= r);
        selection(i) = r;
    end
    
end