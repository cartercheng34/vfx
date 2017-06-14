function d = align_matrix( des1, loc1, des2, loc2, valid, img_w)
%	align_matrix() uses RANSAC to calculate translation vector d
%   des are 1*4 cell that contains features patches
%   loc are 1*4 cell that contains locations of features 
%   d is the displacement vector that maximizes the number of 
%   inliers after the translation. 

match_loc_X = [];
match_loc_Y = [];
for s = 1:4
    descriptors_X = des2{s};
    descriptors_Y = des1{s};
    locations_X = loc2{s};
    locations_Y = loc1{s};
    X = reshape(descriptors_X, 64, [])';
    Y = reshape(descriptors_Y, 64, [])';
    pairs = [];
    if (size(X,1) ~= 0 && size(Y,1) ~= 0) 
        pairs = feature_match(X, Y);
    end
    if (size(pairs, 1) ~= 0)
        for i = 1:size(pairs, 1)
            if (locations_X(pairs(i,1),1) > valid(1) && ...
                locations_X(pairs(i,1),1) < valid(2) && ...
                locations_Y(pairs(i,2),1) > valid(1) && ...
                locations_Y(pairs(i,2),1) < valid(2) && ...
                locations_X(pairs(i,1),2) < img_w / (2^s) && ...
                locations_Y(pairs(i,2),2) > img_w / (2^s))
                match_loc_X = [match_loc_X ; locations_X(pairs(i,1),:)*2^(s-1)];
                match_loc_Y = [match_loc_Y ; locations_Y(pairs(i,2),:)*2^(s-1)];
            end
        end
    end
end

N = size(match_loc_X, 1);
k = 50000;
n = 3;
if n > N
    n = N;
end
thres_d = 3;
inliers_num = 1;

%{
figure; hold on;
scatter(match_loc_X(:,2),match_loc_X(:,1),25,'Marker','x');
scatter(match_loc_Y(:,2),match_loc_Y(:,1),25,'r');

figure; imshow(images(:,:,:,1));
hold on;
scatter(match_loc_Y(:,2),match_loc_Y(:,1),25,'r');
figure; imshow(images(:,:,:,2));
hold on;
scatter(match_loc_X(:,2),match_loc_X(:,1),25,'r');

for i = 1:size(match_loc_X,1)
    figure; imshow(images(:,:,:,8));
    hold on;
    scatter(match_loc_Y(i,2),match_loc_Y(i,1),25,'r');
    figure; imshow(images(:,:,:,9));
    hold on;
    scatter(match_loc_X(i,2),match_loc_X(i,1),25,'r');
    %line([match_loc_X(i,2), match_loc_Y(i,2)],[match_loc_X(i,1), match_loc_Y(i,1)]);
end

hold off;
%}
for iter = 1:k
    idx = randperm(N);
    idx = idx(1:n);
    x = match_loc_X(idx,:);
    y = match_loc_Y(idx,:);
    delta_d = mean(y) - mean(x);
    
    X_trans = match_loc_X;
    X_trans(:,1) = match_loc_X(:,1) + delta_d(1);
    X_trans(:,2) = match_loc_X(:,2) + delta_d(2);
    
    % Count inliers
    distance = sqrt(sum((match_loc_Y - X_trans) .^ 2, 2));
    inliers = distance < thres_d;
    inliers_count = sum(inliers);
    if (inliers_count > inliers_num)
        inliers_num = inliers_count;
        x = match_loc_X(inliers,:);
        y = match_loc_Y(inliers,:);
        d = mean(y) - mean(x);
    end
end

% Plot
% figure; hold on;
% scatter(match_loc_X(:,2)+d(2),match_loc_X(:,1)+d(1),25,'Marker','x');
% scatter(match_loc_Y(:,2),match_loc_Y(:,1),25,'r');
% hold off;

end

