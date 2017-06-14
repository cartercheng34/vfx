
%% read image
disp('Loading images...');
[file_list, exposure_time] = textread('info.txt','%s %f');
exposure_time = exposure_time';
rgb = readImages(file_list);
[row, col, channel, number] = size(rgb);
ln_time = log(exposure_time);
%% random sample
disp('Sampling points...');

sample_n = 400;
lE = zeros(sample_n , channel);
g = zeros(256 , channel);

[location] = sample(sample_n , col , row);
value = zeros( sample_n , number , channel );
for i = 1:channel
    for j = 1:number
        for k = 1:sample_n
            value(k,j,i) = rgb(location(k , 2) , location(k , 1) , i , j);
        end
    end
end
%% camera response curve
disp('Plotting camera response curve...');

l = 10;
for i = 1:channel
    [g(:,i) , lE(:,i)] = gsolve( value(:,:,i), ln_time ,l , weight);
end
ascending = linspace(0 , 255 , 256);
figure
plot(  g(:,1) ,ascending , 'r');
xlabel('log(exposure)'), ylabel( 'pixel value');
title('Red');
figure
plot(  g(:,2) ,ascending , 'g');
xlabel('log(exposure)'), ylabel( 'pixel value');
title('Green');
figure
plot(  g(:,3) ,ascending , 'b');
xlabel('log(exposure)'), ylabel( 'pixel value');
title('Blue');
%% assemble hdr
disp('Constructing hdr image...')
w = weight();
final = hdr(rgb , g , ln_time , w , channel , col ,row , number);
hdrwrite(final,'../result/result.hdr');
disp('HDR file generated.');



