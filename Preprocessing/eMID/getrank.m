function tmprank2 = getrank(tmpdata)
    tmpdata=double(tmpdata);
    tmprank = rank(tmpdata);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Here: alternate computation of the rank by Sven Hoffman
    %tmprank = rank(tmpdata(:,1:min(3000, size(tmpdata,2)))); old code
    covarianceMatrix = cov(tmpdata', 1);
    [~, D] = eig (covarianceMatrix);
    rankTolerance = 1e-7;
    tmprank2=sum (diag (D) > rankTolerance);
    if tmprank ~= tmprank2
        tmprank2 = min(tmprank, tmprank2);
    end
end