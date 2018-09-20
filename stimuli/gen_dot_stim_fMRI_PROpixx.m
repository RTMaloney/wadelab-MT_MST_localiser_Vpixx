function gen_dot_stim_fMRI_PROpixx

% generates sequence of random dot images for MT localiser (speed_pix = .01 for example)
%
% CC 10.02.08
%
% Version _BOLDscreen written 12 Sept 2013 by R Maloney
% Version _PROpixx written May 2016 by R Maloney
% Note that stimulus matrices are still defined here as varying between 0-255.
% They are normalised by 255 prior to presentation in MT_MST_Localiser_Vpixx.m 
% To place them in the scale 0-1. This can only be done by converting the images
% back from unit8 into doubles instead of int16 (because, a background value of 0.5 is obviously not an integer!)


%%% Set the ratio to adjust stimulus size: %%%
% this is the ratio of the PROpixx pixels/deg to the old Dell projector pixels/deg (Sydney); 
% The PROpixx has slightly fewer pixels/deg (46.4) than the Dell one (53), so the ratio is 
% 46.4/53 = 0.8755

SizeRatio = 46.4/53;

PPD = 46.4; %the pixels per degree on the PROpixx
speed_pix = 0.0025; %equivalent to the omega parameter ('w'): this is the same as that set to the original dot stimuli for the Dell projector; gives a speed gradient of 1.2
dot_im_size = 128*SizeRatio;  % dot size
sigma = 24*SizeRatio;         % was 40
sub = 8;            % pixel sub-sampling (ie subsampled to the nearest 8th of a pixel)
sub_dot_size = (dot_im_size/sub)-1; %doesn't seem to be used
dot_density = 0.005;   % was 0.005
stim_size = 1080; %the PROpixx resolution is 1080 x 1920 pixels;
imsize = stim_size;
num_dots = 2000; % was dot_im_size
num_coh_dots = num_dots;
num_frames = 61; % (was 20) so 61 frames is a second at 60 Hz...do we leave this value & simply show the same thing twice, once to each eye? ..probably yes
speed = speed_pix*sub;
div = exp(speed);

% DJM
smooth = 24 * SizeRatio; %for the spatial window

% DJM
images = zeros(imsize,imsize,num_frames,'uint8');

% Spatial window parameters
out_rad = (stim_size)/ 2; % let's use the whole screen; before it was 90% of the screen ie out_rad = (stim_size*.9)/ 2;
%in_rad = stim_size/10;

% DJM
in_rad = PPD*0.5; % let's also make the inner radius smaller, 0.5 deg; before it was 1/12th ie : in_rad = stim_size/12 coming to approx 1.2 deg
%this is the same inner annulus as the retinotopy wedge/rings stimuli

% spatial window array to multiply pointwise with stim ...

spat_wind = ones(stim_size);
for (ii=1:stim_size)
   for (jj=1:stim_size)
      r2 = (ii-(stim_size/2))^2 + (jj-(stim_size/2))^2;
      if (r2 > out_rad^2) 
          spat_wind(ii,jj) = 0; 
      elseif (r2 < in_rad^2) 
          spat_wind(ii,jj) = 0;
          
      % DJM
      elseif (r2 > (out_rad - smooth)^2)
          spat_wind(ii,jj) = cos(pi.*(sqrt(r2)-out_rad+smooth)/(2*smooth))^2;
      elseif (r2 < (in_rad + smooth)^2)
          spat_wind(ii,jj) = cos(pi.*(sqrt(r2)-in_rad-smooth)/(2*smooth))^2;
          
      end
   end
end

%apply gaussian envelope to dots:
for ii = 1:dot_im_size
    gauss_1d(ii) = exp(-(ii-(dot_im_size+1)/2)^2/sigma^2);
end
gauss_2d = gauss_1d' * gauss_1d;

new_dot_pos = ceil(rand(num_dots,2).*stim_size);          % initial dot pos's (was dot_im_size)

% set polarity of carrier dots
pol_mat = mod(1:num_dots,2);

for (f=1:num_frames)
    f 
    stim = zeros(stim_size);
    if (f>1) 
        % update dot positions each frame   
        new_dot_pos = new_dot_pos - imsize/2;
        new_dot_pos = imsize/2 + div.*(new_dot_pos);
        
        % wrap around ...
        out_of_range = new_dot_pos(:,1) > imsize | new_dot_pos (:,1) <= 1 | new_dot_pos(:,2) > imsize | new_dot_pos (:,2) <= 1; % logical array
        num_new_dots = sum(out_of_range);
        rand_angle = 2*pi*rand(num_new_dots,1);
        rand_rad = ((imsize-2)/2).*sqrt(rand(num_new_dots,1));
        new_dot_pos(out_of_range,:) = ones(num_new_dots,2).*(imsize/2) + [rand_rad rand_rad].*[cos(rand_angle) sin(rand_angle)];
    end
    int_pos = floor(new_dot_pos);            % calculate pixel ....
    rem_pos = floor((new_dot_pos-int_pos).*sub);    % ... and subpixel positions
    
    tic
    for (ii=1:num_dots)
        ii
        xrem = rem_pos(ii,1);
        yrem = rem_pos(ii,2);
        
        xint = int_pos(ii,1);
        yint = int_pos(ii,2);
        
        % t2 is subsampled image of dot, size (dot_im_size/sub)-1 square ...
        t1 = resample(gauss_2d(sub-xrem:dot_im_size-1-xrem,:),1,sub);
        t2 = resample(t1(:,sub-yrem:dot_im_size-1-yrem)',1,sub);  
        
        % add dot to stimulus array 
        if (pol_mat(ii) > 0.5)
            stim = wrap_add(stim,t2,xint,yint,1);
        else
            stim = wrap_add(stim,t2,xint,yint,-1);
        end       
    end
    toc
    
    stim = round(stim.*spat_wind.*128 + ones(size(stim)).*128);
    stim = max(min(stim,256),1); % restrict range to 1-255 ...
    
    %stim = round(stim.*spat_wind.*0.5 + ones(size(stim)).*0.5);
    %stim = max(min(stim,1),0); % restrict range to 0-1 ...
    
    
    % DJM
    images(:,:,f) = stim;
end

% DJM

description.genDate = datestr(now);
description.speed = speed_pix;
description.dot_density = dot_density;
description.num_dots = num_dots;
description.num_frames = num_frames;

save('dots_PROpixx.mat','images','description');

% pcolor(stim);
%     shading flat;
%     colormap(gray);
%     caxis([0 255]);
%     axis off;
%     title(f);

%A bit about the speed parameters: 19/9/13

% The mean speed in the radial motion random dot kinematograms is given by 
% ? * frame rate (in Hz) * mean radius (in degs visual angle)
% With the current parameters,
% ? = 0.0025 * 8 (dots are subsampled by 8 pixels)
% frame rate = 60 Hz
% The expression for the mean radius is:
% mean_radius = (2/3)*(rmax^3 - rmin^3)/(rmax^2 - rmin^2)
% where, 	rmin = inner radius of annulus, and 
% 			rmax = outer radius of annulus.
% So on the projector we had rmin = 1.2 deg and rmax = 6.4 deg. Using these values we get a mean radius of 4.393 deg. This gives a mean speed of:
% Mean speed = (0.0025 * 8) * 60 * 4.393 = 5.2716 or ~5.3 deg/s. 
% Note that the value for ? was already set in the old MT localiser before it was adapted to also localise MST (by presenting moving dots in only the left or right 120° of the display).
% On the BOLDscreen we’re going a bit larger, rmin = 0.4 deg and rmax = 7.6 deg.
% 7.6 is the max radius on the display when the BOLDscreen is positioned at a viewing distance of 121.5 cm (including mirror). 0.4 deg is the same inner radius as the rings and wedges used in the retinotopic mapping stimuli.
% With these values we get a mean radius of:
% mean_radius = (2/3)*( 7.6^3 - 0.4^3)/( 7.6^2 - 0.4^2) = 5.08 deg
% This gives a mean speed of:
% Mean speed = (0.0025 * 8) * 60 * 5.08 = 6.096 or ~ 6.1 deg/s.
% Note that this mean speed is not equivalent to the mean speed on the projector of 5.3 deg/s. However, the value (0.0025 * 8) * 60 = 1.2, which is the speed gradient. It is more important that the speed gradient is the same rather than the mean speed, which is more or less arbitrary. If we wanted to keep the mean speed the same we would need to reduce the ? parameter by a factor of 0.8689 (or 5.3/6.1) which would give (0.0025 * 0.8689 * 8). 
