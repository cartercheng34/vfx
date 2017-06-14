function [feature_descriptor , total_location , orientation] = MSOP(img , layer , sigma_p , sigma_d , sigma_i , threshold , sigma_o)
    gray = rgb2gray(img);
    %gray = im2double(gray);
    pyramid = cell(1 , layer); %layer = 5
    pyramid{1 , 1} = gray;
    height = zeros(1 , layer);
    width = zeros(1 , layer);
    feature_descriptor = cell(1 , layer);
    orientation = cell(1 , layer);
    total_location = cell(1 , layer);
    pyramid_2 = cell(1 , layer);
    pyramid_2{1 , 1} = gray;
    
    
    for i = 1:layer-1
        tmp = imgaussfilt(pyramid{1 , i} , sigma_p); %sigma_p = 1
        tmp_o = imgaussfilt(pyramid_2{1 , i} , sigma_o); %sigma_o = 4.5
        pyramid{1 , i+1} = impyramid(tmp , 'reduce');     
        pyramid_2{1 , i+1} = impyramid(tmp_o , 'reduce');
    end
    for i = 1:layer
        [height(1 , i) , width(1 , i) , channel] = size(pyramid{1 , i});
    end
    
    f = cell(1 , layer);
    pos = cell(1 , i);
    %distribution = zeros(1 , layer);
    for i = 1:layer
        max_num = 500;
        ori_max = max_num;
        
        f{1 , i} = zeros(height(1 , i) , width(1 , i));
        pyramid{1 , i} = pyramid{1 , i} ; %nomalized
        [Ix , Iy] = imgradientxy(pyramid{1 , i} , 'central');
        Ix2 = Ix.^2;
        Iy2 = Iy.^2;
        Ixy = Ix .* Iy;
        Sx2 = imgaussfilt(Ix2 , sigma_i);
        Sy2 = imgaussfilt(Iy2 , sigma_i);
        Sxy = imgaussfilt(Ixy , sigma_i);
        for y = 1:height(1 , i)
            for x = 1:width(1 , i)
                M = [Sx2(y, x) Sxy(y , x) ; Sxy(y , x) Sy2(y , x)];
                f{1 , i}(y , x) = det(M) / trace(M);  %fHM
                %if x < 21 | y<21 | (width(1 , i)-x) < 21 | (height(1 , i) - y) < 21
                %    f{1 , i}(y , x) = 0;
                %end
            end
        end        
        mask = ones(3); 
        mask(5) = 0;
        B = ordfilt2(f{1 , i},8,mask);
        local_max = f{1 , i} > B;
        final = local_max & (f{1 , i} > threshold);
        [row , col] = find(final);
        pos{1 , i} = [row , col];% record local max and > threshold point location
        
        [distribution] = ANMS( pos{1 , i} , max_num , f{1 , i} , height(1 , i) , width(1 , i));
        max_num = find(distribution(: , 1) , 1 , 'last');% find the index of non-zero in distribution
        %xm = zeros(max_num , 2);
        if max_num ~= ori_max
            distribution = distribution(distribution > 0);
            distribution = reshape(distribution , max_num , 2);
        end
        %{
        for k = 1:max_num
            xm(k , :) = sub_refine(distribution(k , 1), distribution(k , 2) , f{1 , i});
        end
        distribution(: , 2) = distribution(: , 2) + xm(: , 1);
        distribution(: , 1) = distribution(: , 1) + xm(: , 2);
        %}
        %{
        floor_x = floor(distribution(: , 2));
        floor_y = floor(distribution(: , 1));
        ceil_x = ceil(distribution(: , 2));
        ceil_y = ceil(distribution(: , 1));
        area1 = (ceil_x(:) - distribution(: , 2)) * (ceil_y(:) - distribution(: , 1)); %右上
        area2 = (ceil_x(:) - distribution(: , 2)) * (distribution(: , 1) - floor_y(:)); %右下
        area3 = (distribution(: , 2) - floor_x(:)) * (distribution(: , 1) - floor_y(:)); % 左下
        area4 = (distribution(: , 2) - floor_x(:)) * (ceil_y(:) - distribution(: , 1) ); % 左上
        tmp_value = area1 * f{1 , i}(ceil_y(:) , ceil_x(:)) + area2 * f{1 , i}(floor_y(:) , ceil_x(:))...
                    + area3 * f{1 , i}(floor_y(:) , floor_x(:)) + area4 * f{1 , i}(ceil_y(:) , floor_x(:));
        %}
        theta = zeros(max_num , 1);
        tmp_value = zeros(max_num , 1);
        output = zeros(8 , 8 , max_num);
        
        for k = 1:max_num
            theta(k) = cal_gradient(distribution(k , 1) , distribution(k , 2) , pyramid_2{1 , i});            
        end
        for k = 1:max_num
            tmp_value(k) = sub_pixel_value(distribution(k , 1) , distribution(k , 2) , pyramid{1 , i});
            output(: , : , k) = make_descriptor(distribution(k , 1) , distribution(k , 2) , theta(k) , pyramid{1 , i});
        end       
        feature_descriptor{1 , i} = output;
        total_location{1 , i} = distribution;
        orientation{1 , i} = theta(:);
    end  
    
    
end