function images = readImages(folder)
       
    
    files = dir([folder, '/*.', 'jpg']);
    number = length(files);    
    [h, w, ~] = size(imread([folder, '/', files(1).name]));
    
    images = zeros(h , w , 3 , number);
    for i = 1:number
        filename = [folder, '/', files(i).name];
        img = imread(filename);   
            
        images(:,:,:,i) = img;  
    end
    
end