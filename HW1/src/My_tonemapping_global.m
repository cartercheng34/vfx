function rgb = My_tonemapping( hdr , a )
% My_tonemapping Perform tonemapping on hdr image
%   'hdr' is a n*m*3 RGB matrix
%   This function performs tonemapping on 'hdr'
%   Using Photographic tone reproduction

[n, m, ~] = size(hdr);
N = n * m;
rgb = zeros(n, m, 3);
rgb = uint8(rgb);
for i = 1:3
    Lw = hdr(:,:,i);
    delta = 0.001;
    Lw_bar = exp(sum(sum(log(Lw + delta))) / N);
    L = Lw * a / Lw_bar;
    Lmax = max(Lw(:));
    Ld = (L .* (1 + L / (Lmax ^ 2))) ./ (1 + L);
    rgb(:,:,i) = uint8(Ld * 255);
end

end

