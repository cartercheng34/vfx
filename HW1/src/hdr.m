function hdr_image = hdr (image , g , ln_time , weight , channel , col , row , number)

    ln_E = zeros(row, col, 3);

%assemble
    for n = 1:channel % channel
        for i = 1:row 
            for j = 1:col
                w_sum = 0;
                g_sum = 0;
                for k = 1:number % pic
                    w_sum = w_sum + weight(image(i , j , n , k)+1);
                    g_sum = g_sum + weight(image(i , j , n , k)+1) * (g(image(i , j , n , k)+1)-ln_time(k));
                end
                
                if w_sum == 0
                    ln_E(i , j , n) = 0;
                else
                    ln_E(i, j, n) = g_sum / w_sum;
                end
            end
        end
    end   
    
    hdr_image = exp(ln_E);
           

end