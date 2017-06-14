function images = readImages(file_list)

    number = length(file_list);    
    info = imfinfo(char(file_list(1)));
    h = info.Height;
    w = info.Width;
    
    images = zeros(h , w , 3 , number);
    
    for i = 1:number
        img = imread(char(file_list(i)));
        images(:,:,:,i) = img;
    end
    
end