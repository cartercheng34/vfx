function [theta] = cal_gradient(y , x , f) % x , y are double
    Iy = (sub_pixel_value(y+1 , x , f) - sub_pixel_value(y-1 , x , f)) / 2;
    Ix = (sub_pixel_value(y , x+1 , f) - sub_pixel_value(y , x-1 , f)) / 2;
    if Iy == 0 & Ix == 0
        theta = 0;
    else theta = atand(Iy / Ix);
    end
end