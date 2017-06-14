function [descriptor] = make_descriptor(location_y , location_x , theta , img)
    patch_size = 40;
    descriptor_size = 8;
    output = rotateAround(img , location_y , location_x , 90 - theta , 'bilinear');
    counter = 1;
    counter2 = 1;
    
    location = zeros(patch_size^2 , 2);

    for j = -20:19
        for i = -20:19
            location(counter , 1) = location_y + i ;
            location(counter , 2) = location_x + j ; 
            counter = counter +1;
        end
    end
    
    gg = zeros(patch_size^2 , 1);
    for i = 1:patch_size^2
        gg(i) = sub_pixel_value(location(i , 1) , location(i , 2) , output);
    end
    patch = reshape(gg , [patch_size , patch_size]);
    descriptor = zeros(descriptor_size^2 , 1);
    counter = 1;
    for n = 1:descriptor_size^2
        remain = mod(n , descriptor_size);
        record = patch(counter:counter+4 , counter2:counter2+4);       
        
        descriptor(n) = sum(sum(record))/25;
        counter = counter + 5;
        if remain == 0
            counter = 1;
            counter2 = counter2 + 5;
        end
    end
    descriptor = (descriptor - mean(descriptor)) / sqrt(var(descriptor));
    descriptor = reshape(descriptor , [descriptor_size , descriptor_size]);
end