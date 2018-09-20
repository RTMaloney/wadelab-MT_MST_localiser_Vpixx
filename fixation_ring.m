function image = fixation_ring(diameter,ring_width,bg_colour)
% $Id: fixation_ring.m 6 2007-08-05 23:08:12Z damienm $
% image = fixation_ring(diameter,ring_width,bg_colour)


    centre = diameter/2;
    
    image = ones(diameter,diameter);
    
    image = image.*bg_colour;
    
    for theta = 0:.001:2*pi
        
        fill_col = 0;
        
        if (theta > 0 && theta < pi/2) || (theta > pi && theta < 3*pi/2)
            fill_col = 255;
        end
        
        for r=ring_width:diameter/2-1
            [x,y] = pol2cart(theta,r);
            image(round(x+centre),round(y+centre)) = fill_col;
        end
    end
            
    
end