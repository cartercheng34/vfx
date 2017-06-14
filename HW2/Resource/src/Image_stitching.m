clear;

%% read images and resize
folder = input('Enter the path to folder:  ' , 's');
focal = input('Enter the focal length:  ');
disp('Loading images...');
images = readImages(folder);
imsize = [size(images,1) , size(images,2)];
if (min(imsize) > 800)
    resize_scale = ceil(min(imsize) / 800); 
    focal = focal / resize_scale;
    images = imresize(images,  1/resize_scale);
end

%% cylindrical warping
disp('Warping to cylindrical...');
images_warp = cylindrical_warp(images, focal);
[img_h, img_w, ~, ~] = size(images_warp);
crop = 1;
while 1
    if images_warp(floor(img_h/2),crop,1,1) ~= 0
        break;
    else crop = crop + 1; 
    end
end
images_warp = images_warp(:,crop:img_w-crop,:,:);
[img_h, img_w, ~, number] = size(images_warp);

%% feature detection
disp('Detecting features...');
layer = 4;
sigma_p = 1;
sigma_o = 4.5;
threshold = 7;
sigma_i = 1.5;
sigma_d = 1;
descriptors = cell(1, number);
locations = cell(1, number);
orientations = cell(1 , number);
for i = 1:number
    disp(['   Image #' , num2str(i)]);
    [descriptors{i} , locations{i} , orientations{i}] = MSOP(images_warp(:,:,:,i), layer, sigma_p, sigma_d, sigma_i, threshold, sigma_o);
end

%% feature matching
disp('Matching features...');
D = zeros(number, 2);
valid = [0, 0];
valid(1) = find(images_warp(:,1,1,1),1);
valid(2) = img_h - valid(1);
for i = 1:number-1
    d = align_matrix(descriptors{i}, locations{i}, descriptors{i+1}, locations{i+1}, valid, img_w);
    D(i+1,:) = D(i,:) + d;
end

% adjust drift
% D = adjust_drift(D);

%% aligning and blending
disp('Assembling panorama...');
panorama = uint8(multiband_blending(images_warp, D));

imshow(panorama);

save = input('\nSave Image? (Y/n)  ' , 's');
if (save == 'Y' || save == 'y')
    imwrite(panorama, '../result/result.jpg');
    disp('Save image to ../result ');
end