match_loc_X = [];
match_loc_Y = [];
for s = 1:4
    descriptors_X = des2{s};
    descriptors_Y = des1{s};
    locations_X = loc2{s};
    locations_Y = loc1{s};
    X = reshape(descriptors_X, 64, [])';
    Y = reshape(descriptors_Y, 64, [])';
    pairs = feature_match(X, Y);
    match_loc_X = [match_loc_X ; locations_X(pairs(:,1),:)*2^(s-1)];
    match_loc_Y = [match_loc_Y ; locations_Y(pairs(:,2),:)*2^(s-1)];
end

d = align_matrix(match_loc_X, match_loc_Y);
d = round(d); % d(2) should be positive

pano = zeros(1368+abs(d(1)), 912+d(2), 3);
pano_X = pano;
pano_Y = pano;
if (d(1) < 0)
    pano_X(-d(1):-d(1)+1368, 1:912, :) = w(:,:,:,7);
    pano_Y(1:1368, d(2)+1:d(2)+912, :) = w(:,:,:,8);
else     
    pano_X(1:1368, 1:912, :) = w(:,:,:,7);
    pano_Y(1+d(1):1368+d(1), d(2)+1:d(2)+912, :) = w(:,:,:,8);
end

M = floor(log2(max(size(pano_X))));
im1p = cell(1,M);
im2p = cell(1,M);
im1p{1} = pano_X;
im2p{1} = pano_Y;
mp = cell(1,M);
mp{1} = [ones(size(pano_X,1), floor(size(pano_X,2)/2)+1, 3) , zeros(size(pano_X,1), floor(size(pano_X,2)/2), 3)];

 % Gaussian pyramid
for n = 2 : M
    % downsample image
    im1p{n} = imresize(im1p{n-1}, 0.5);
    im2p{n} = imresize(im2p{n-1}, 0.5);
    % downsample blending mask
    mp{n} = imresize(mp{n-1}, 0.5, 'bilinear');
end
 
 % Laplician pyramid
for n = 1 : M-1
    im1p{n} = im1p{n} - imresize(im1p{n+1}, [size(im1p{n},1), size(im1p{n},2)]);
    im2p{n} = im2p{n} - imresize(im2p{n+1}, [size(im2p{n},1), size(im2p{n},2)]);   
end   
 
 % Multi-band blending Laplician pyramid
for n = 1 : M
    imp{n} = im1p{n} .* mp{n} + im2p{n} .* (1-mp{n});
end
 
 % Laplician pyramid reconstruction
im = imp{M};
for n = M-1 : -1 : 1
    im = imp{n} + imresize(im, [size(imp{n},1) size(imp{n},2)]);
end



%{
[Lh Lv] = imgrad(pano_Y);
[Gh Gv] = imgrad(pano_X);

X = pano_Y;
Fh = Lh;
Fv = Lv;

msk_width = 912 - d(2);
msk_height = 1368 + abs(d(1));
LX = 123;
LY = 125;
GX = 89;
GY = 101;

X(1:msk_height, d(2)+1:912, :) = pano_X(1:msk_height, d(2)+1:912, :);
Fh(1:msk_height, d(2)+1:912, :) = Gh(1:msk_height, d(2)+1:912, :);
Fv(1:msk_height, d(2)+1:912, :) = Gv(1:msk_height, d(2)+1:912, :);

msk = zeros(size(pano));
msk(1:msk_height, d(2)+1:912, :) = 1;

tic;
Y = PoissonJacobi( X, Fh, Fv, msk );
toc
imwrite(uint8(Y),'Yjc.png');
tic;
Y = PoissonGaussSeidel( X, Fh, Fv, msk );
toc
imwrite(uint8(Y),'Ygs.png');
%}