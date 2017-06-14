function [output] = sub_pixel_value(y , x , f) % x , y��double
    area1 = (ceil(x) - x) * (ceil(y) - y); %�k�W
    area2 = (ceil(x) - x) * (y - floor(y)); %�k�U
    area3 = (x - floor(x)) * (y - floor(y)); % ���U
    area4 = (x - floor(x)) * (ceil(y) - y); % ���W
    output = area1 * double(f(ceil(y) , ceil(x))) + area2 * double(f(floor(y) , ceil(x)))...
             + area3 * double(f(floor(y) , floor(x))) + area4 * double(f(ceil(y) , floor(x)));
end