function w = weight()    
    w = [0:1:255];
	for i = 1:256
        if i > 128
            w(i) = 256-i;
        end
    end
end