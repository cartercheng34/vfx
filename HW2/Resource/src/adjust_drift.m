function D_adjust = adjust_drift( D )
%   adjust_drift() adjusts the drift by simple translation
%   D is a n*2 vector that contains the displacement of each image 

number = size(D , 1);
total_drift = D(number, 1);
drift_count = 0;
for i = 1:number-1
    if (total_drift > 0 && D(i,1) < D(i+1,1))
        drift_count = drift_count + 1;
    elseif (total_drift < 0 && D(i,1) > D(i+1,1))
        drift_count = drift_count + 1;
    end
end
drift = 0;
step = total_drift / drift_count;
D_adjust = D;
if (abs(step) > 3)
    if (step > 0) step = 3; end
    if (step < 0) step = -3; end
end
for i = 2:number
    if (total_drift > 0 && D(i-1,1) < D(i,1))
        drift = drift + step;
    elseif (total_drift < 0 && D(i-1,1) > D(i,1))
        drift = drift + step;
    end
    D_adjust(i,1) = D(i,1) - drift;
end

end

