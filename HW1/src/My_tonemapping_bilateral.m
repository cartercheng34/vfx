function rgb = My_tonemapping_bilateral( hdr , a )
% My_tonemapping_bilateral Perform tonemapping on hdr image
%   'hdr' is a n*m*3 RGB matrix
%   This function performs tonemapping on 'hdr'
%   Using Bilateral filtering

[n, m, ~] = size(hdr);
N = n * m;
I = 0.3*hdr(:,:,1) + 0.59*hdr(:,:,2) + 0.11*hdr(:,:,3);
delta = 0.001;
log_I = log(I+delta);
R = hdr(:,:,1) ./ I;
G = hdr(:,:,2) ./ I;
B = hdr(:,:,3) ./ I;
sigma_s = 0.02 * n;
sigma_r = 0.1;
kernel_size = uint8(sigma_s);
kernel_size = double(kernel_size);
[x,y] = meshgrid(-kernel_size:kernel_size, -kernel_size:kernel_size);
x = double(x);
y = double(y);
f = exp(-(x.^2+y.^2)/(2*sigma_s^2));
f = f./max(f(:));

max_I = max(log_I(:));
min_I = min(log_I(:));
nb = (max_I-min_I) / sigma_r
J = zeros(n,m);
for i = 0:nb
    i
    I_i = min_I + i * sigma_r;
    g = exp(-((log_I-I_i).^2) ./ (2*sigma_r^2));
    k = conv_fft(g,f) + 0.001;
    h_i = g .* log_I;
    h = conv_fft(h_i,f);
    J_i = h ./ k;
    J = J + J_i .* double(log_I>min_I+i*sigma_r) .* double(log_I<=min_I+(i+1)*sigma_r);
end
log_base = J;

log_detail = log_I - log_base;
base = exp(log_base);
Lw_bar = exp(mean(log_base(:)));
L = base * a / Lw_bar;
Lmax = max(base(:));
base = (L .* (1 + L / (Lmax ^ 2))) ./ (1 + L);
out_I = exp(log(base)+log_detail);
R = R .* out_I;
G = G .* out_I;
B = B .* out_I;
rgb = R*0.98;
rgb(:,:,2) = G;
rgb(:,:,3) = B;
end

function x = conv_fft(a , b)

[m,n] = size(a);
[mb,nb] = size(b); 
% output size 
mm = m + mb - 1;
nn = n + nb - 1;

% pad, multiply and transform back
C = ifft2(fft2(a,mm,nn).* fft2(b,mm,nn));

% padding constants (for output of size == size(A))
padC_m = ceil((mb-1)./2);
padC_n = ceil((nb-1)./2);

% frequency-domain convolution result
x = C(padC_m+1:m+padC_m, padC_n+1:n+padC_n); 

end

