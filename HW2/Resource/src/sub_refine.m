function [xm] = sub_refine(y , x , f)
    
    
    deria_x  = (f(y , x+1) - f(y , x-1)) / 2;
    deria_y = (f(y-1 , x) - f(y+1 , x)) / 2;
    deria_x2 = f(y , x+1) - 2*f(y , x) + f(y , x-1);
    deria_y2 = f(y+1 , x) - 2*f(y , x) + f(y-1 , x);
    deria_xy = 1/4 * ( f(y - 1 , x - 1) - f(y + 1 , x - 1) - f(y - 1 , x + 1) - f(y + 1 , x + 1));
    
    tmp = [deria_x2 , deria_xy ; deria_xy , deria_y2];
    xm = -1 * inv(tmp) * [deria_x ; deria_y];
end