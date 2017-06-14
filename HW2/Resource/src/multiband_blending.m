function panorama = multiband_blending( images, D )
%   multiband_blending() stitch and blend the images according to D
%   images is a h*w*3*num matrix that contains num images
%   D is the diplacement vectors of images respectively

[imheight, imwidth, ~, num] = size(images); 
M = floor(log2(max([imheight, imwidth])));
M = 5;
imps = cell(num,M);
mp = cell(num,M);
Dr = D; 
Dr(:,1) = D(:,1) - min(D(:,1));
Dr = round(Dr);
bkground = zeros(max(Dr(:,1))+imheight , round(D(num,2))+imwidth, 3);
[bkheight, bkwidth, ~, ~] = size(bkground);
sep = zeros(1, num+1);
sep(num+1) = bkwidth; 
for i = 2:num
    sep(i) = round((D(i-1,2) + D(i,2) + imwidth) / 2);
end
for i = 1:num
    tmp = bkground;
    tmp(1+Dr(i,1):imheight+Dr(i,1), 1+Dr(i,2):imwidth+Dr(i,2), :) = images(:,:,:,i);
    imps{i,1} = tmp;
    tmp = bkground;
    tmp(:,1+sep(i):sep(i+1),:) = 1;
    mp{i,1} = tmp;
end
%im1p{1} = pano_X;
%im2p{1} = pano_Y;

%mp = cell(1,M);
%mp{1} = [ones(size(pano_X,1), floor(size(pano_X,2)/2)+1, 3) , zeros(size(pano_X,1), floor(size(pano_X,2)/2), 3)];

 % Gaussian pyramid
for n = 2 : M
    % downsample image
    for i = 1:num
        imps{i,n} = imresize(imps{i,n-1}, 0.5);
        mp{i,n} = imresize(mp{i,n-1}, 0.5, 'bilinear');
    end
    
    %im1p{n} = imresize(im1p{n-1}, 0.5);
    %im2p{n} = imresize(im2p{n-1}, 0.5);
    % downsample blending mask
    %mp{n} = imresize(mp{n-1}, 0.5, 'bilinear');
end
 
 % Laplician pyramid
for n = 1 : M-1
    for i = 1:num
        imps{i,n} = imps{i,n} - imresize(imps{i,n+1}, [size(imps{i,n},1), size(imps{i,n},2)]);
    end
    %im1p{n} = im1p{n} - imresize(im1p{n+1}, [size(im1p{n},1), size(im1p{n},2)]);
    %im2p{n} = im2p{n} - imresize(im2p{n+1}, [size(im2p{n},1), size(im2p{n},2)]);   
end   
 
 % Multi-band blending Laplician pyramid
imp = cell(1,M);
for n = 1 : M
    imp{n} = imps{1,n} .* mp{1,n};
    for i = 2:num
        imp{n} = imp{n} + imps{i,n} .* mp{i,n};
    end
end
 
 % Laplician pyramid reconstruction
im = imp{M};
for n = M-1 : -1 : 1
    im = imp{n} + imresize(im, [size(imp{n},1) size(imp{n},2)]);
end

panorama = im;

end

