function [warped_image] = cylindrical_warp(img , focal)
    [height, width, ~, number] = size(img);
    center_x = width / 2;
    center_y = height / 2;
    warped_image = zeros(height , width , 3 , number , 'uint8');
    for i = 1:number
        for y = 1:height
            for x = 1:width
                warped_x = focal * atan((x - center_x)/focal) + center_x;
                warped_y = focal * (y - center_y)/sqrt(focal^2 + (x - center_x)^2) + center_y;
                warped_x = round(warped_x);
                warped_y = round(warped_y);
                if (warped_x <= width) && (warped_y <= height)
                    warped_image(warped_y , warped_x , : , i) = img(y , x , : , i );            
                else warped_image(warped_y , warped_x , : , i ) = 0;
                end    
            end
        end
    end
end