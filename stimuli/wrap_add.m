function big = wrap_add(big,small,xoff,yoff,sign)

[bx, by] = size(big);
[sx, sy] = size(small);

if (sign == 1)
 if (xoff+sx>bx+1)
   if (yoff+sy>by+1)   % wrap around x & y
      big(xoff:bx,yoff:by) = big(xoff:bx,yoff:by) + small(1:bx-xoff+1,1:by-yoff+1);
      big(1:sx-bx+xoff-1,yoff:by) = big(1:sx-bx+xoff-1,yoff:by) + small(bx-xoff+2:sx,1:by-yoff+1);
      big(xoff:bx,1:sy-by+yoff-1) = big(xoff:bx,1:sy-by+yoff-1) + small(1:bx-xoff+1,by-yoff+2:sy); 
      big(1:sx-bx+xoff-1,1:sy-by+yoff-1) = big(1:sx-bx+xoff-1,1:sy-by+yoff-1) + small(bx-xoff+2:sx,by-yoff+2:sy);
   else              % wrap around x only
      big(xoff:bx,yoff:yoff+sy-1) = big(xoff:bx,yoff:yoff+sy-1) + small(1:bx-xoff+1,:);
      big(1:sx-bx+xoff-1,yoff:yoff+sy-1) = big(1:sx-bx+xoff-1,yoff:yoff+sy-1) + small(bx-xoff+2:sx,:); 
   end
 elseif (yoff+sy>by+1)  % wrap around y only 
   big(xoff:xoff+sx-1,yoff:by) = big(xoff:xoff+sx-1,yoff:by) + small(:,1:by-yoff+1); 
   big(xoff:xoff+sx-1,1:sy-by+yoff-1) = big(xoff:xoff+sx-1,1:sy-by+yoff-1) + small(:,by-yoff+2:sy); 
 else 
%      xoff
%      yoff
   big(xoff:xoff+sx-1,yoff:yoff+sy-1) = big(xoff:xoff+sx-1,yoff:yoff+sy-1) + small;
 end
elseif (sign == -1)
  if (xoff+sx>bx+1)
   if (yoff+sy>by+1)   % wrap around x & y
      big(xoff:bx,yoff:by) = big(xoff:bx,yoff:by) - small(1:bx-xoff+1,1:by-yoff+1);
      big(1:sx-bx+xoff-1,yoff:by) = big(1:sx-bx+xoff-1,yoff:by) - small(bx-xoff+2:sx,1:by-yoff+1);
      big(xoff:bx,1:sy-by+yoff-1) = big(xoff:bx,1:sy-by+yoff-1) - small(1:bx-xoff+1,by-yoff+2:sy); 
      big(1:sx-bx+xoff-1,1:sy-by+yoff-1) = big(1:sx-bx+xoff-1,1:sy-by+yoff-1) - small(bx-xoff+2:sx,by-yoff+2:sy);
   else              % wrap around x only
      big(xoff:bx,yoff:yoff+sy-1) = big(xoff:bx,yoff:yoff+sy-1) - small(1:bx-xoff+1,:);
      big(1:sx-bx+xoff-1,yoff:yoff+sy-1) = big(1:sx-bx+xoff-1,yoff:yoff+sy-1) - small(bx-xoff+2:sx,:); 
   end
 elseif (yoff+sy>by+1)  % wrap around y only 
   big(xoff:xoff+sx-1,yoff:by) = big(xoff:xoff+sx-1,yoff:by) - small(:,1:by-yoff+1); 
   big(xoff:xoff+sx-1,1:sy-by+yoff-1) = big(xoff:xoff+sx-1,1:sy-by+yoff-1) - small(:,by-yoff+2:sy); 
 else 
%      xoff
%      yoff
   big(xoff:xoff+sx-1,yoff:yoff+sy-1) = big(xoff:xoff+sx-1,yoff:yoff+sy-1) - small;
 end 
end

 