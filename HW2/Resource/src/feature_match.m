function pairs = feature_match( I_1, I_2 )
%   feature_match() matches the features of two input feature sets
%   I_1, I_2 are feature sets of two images.
%   

thres = 5;
[idx, d] = knnsearch(I_1, I_2);
sorted = sortrows([idx, d, (1:size(idx,1))']);
pairs = [];
id = 0;
for i = 1:size(idx,1)
    if (id ~= sorted(i,1))
        id = sorted(i,1);
        if (sorted(i,2) < thres)
            pairs = [pairs; [sorted(i,1), sorted(i,3)]];
        end
    end
end


%{
nb_I1 = size(I_1, 1); 
nb_I2 = size(I_2, 1);

for i = 1:nb_I1
    p_1 = I_1(i,:,:);
    match = 0;
    err_min = 1000000;   % Initial error set to infinite
    for j = 1:nb_I2
        p_2 = I_2(j,:,:);
        err = sum(sum((p_1 - p_2) .^ 2));
        if (err < err_min)
            err_min = err;
            match = j;
        end
    end
    
end
%}



end

