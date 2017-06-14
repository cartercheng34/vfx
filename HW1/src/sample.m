function [location] = sample (sample_n , col , row)
    %name = imread('img07.jpg');
    %imshow(name);
    location = zeros(sample_n , 2);
    for i=1:sample_n
        location(i , 1) = round (randi([1 , col]));
        location(i , 2) = round(randi([1 , row]));
    end
        
end