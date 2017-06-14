function [output] = sub_pixel_value(y , x , f) % x , y為double
    area1 = (ceil(x) - x) * (ceil(y) - y); %右上
    area2 = (ceil(x) - x) * (y - floor(y)); %右下
    area3 = (x - floor(x)) * (y - floor(y)); % 左下
    area4 = (x - floor(x)) * (ceil(y) - y); % 左上
    output = area1 * double(f(ceil(y) , ceil(x))) + area2 * double(f(floor(y) , ceil(x)))...
             + area3 * double(f(floor(y) , floor(x))) + area4 * double(f(ceil(y) , floor(x)));
end