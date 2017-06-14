function [distribution] = ANMS(pos , max_num , f , height , width )
    [size_y , size_x] = size(pos);
    distance = zeros(1 , size_y);%record all pair of features' distance info 
    radius = zeros(1 , size_y);
    distribution = zeros(max_num , 2);
    for i = 1:size_y
        for y = 1:size_y            
            if f(pos(i , 1) , pos(i , 2)) <  f(pos(y , 1) , pos(y , 2))*0.9 & i~=y
                distance(1 , y) = sqrt( (pos(i , 1) - pos(y , 1))^2 + (pos(i , 2) - pos(y , 2))^2 );                    
            else distance(1 , y) = 10^7;
            end            
        end
        [radius(1 , i) , index] = min(distance(1 , :));
    end
    
    %{
    for i = 1:size_y
        [radius(1 , i) , index] = min(distance(i , :)); % 從第一個到size_y個feature point的radius
    end
    %}
    [sorted , I] = sort(radius(1 , :) , 'descend');
    [r,c] = ind2sub(size(radius),I(1:size_y));  %//find out the first max number( parameter = max_num)
    counter = 1;
    xm = zeros(size_y , 2);
    for i = 1:size_y
        if pos(i , 1)>1 & pos(i , 2)>1 & pos(i , 2)~=width & pos(i , 1)~=height
            xm(i , :) = sub_refine(pos(i , 1), pos(i , 2) , f);
        else xm(i , :) = 0;
        end
    end
    for i = 1:size_y
        %{
        radius(r(i) , c(i))
        index(c(i)) 
        distance(c(i) , index(c(i)))
        %}
        
        %xm(pos(c(i) , :) = sub_refine(pos(c(i) , 1), pos(c(i) , 2) , f); %先x在y     
        refine_x = pos(c(i) , 2) + xm(c(i) , 1);
        refine_y = pos(c(i) , 1) + xm(c(i) , 2);
        
        if refine_y > 21 & refine_x > 21 & (width - refine_x) > 21 & (height - refine_y) > 21
            distribution(counter , 1) = refine_y; %location y 
            distribution(counter , 2) = refine_x;
            counter = counter + 1;
        end
        if counter > max_num
            break;
        end
        
    end
end