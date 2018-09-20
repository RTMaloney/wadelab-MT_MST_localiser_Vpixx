function gen_dot_stim_fMRI_BOLDscreen

% generates sequence of random dot images for MT localiser (speed_pix = .01 for example)
%
% CC 10.02.08

%Version _BOLDscreen written 12 Sept 2013 by R Maloney
%This is to generate dot stimuli for display on the CRS BOLDscreen (saved as dots_BOLDscreen.mat)
%These are designed to have the same stimulus parameters (eg size, density, speed etc) as the version used on the projector,
%except the stimulus annulus is wider.

%%% Set the ratio to adjust stimulus size: %%%
%this is the ratio of the BOLDscreen pixels/deg to the projector pixels/deg; because the BOLDscreen has a greater 
%pixel density (79 pixels/deg), we need to increase the number of pixels in the stimuli to match them to the size they would have 
%appeared on the projector (a density of about 53 pixels/deg) so 79/53 = 1.4906 or about 1.5 
SizeRatio = 1.5;

PPD = 79; %the pixels per degree on the BOLDscreen
speed_pix = 0.0025; %equivalent to the omega parameter ('w'): this is the same as that set to the original dot stimuli for the projector; gives a speed gradient of 1.2
dot_im_size = 128*SizeRatio;  % dot size
sigma = 24*SizeRatio;         % was 40
sub = 8;            % pixel sub-sampling (ie subsampled to the nearest 8th of a pixel)
sub_dot_size = (dot_im_size/sub)-1; %doesn't seem to be used
dot_density = 0.005;   % was 0.005
stim_size = 1200; %the BOLDscreen resolution is 1200 x 1920 pixels; 768; %192;  % was 64
imsize = stim_size;
num_dots = 2000; % was dot_im_size
num_coh_dots = num_dots;
num_frames = 61; % was 20
speed = speed_pix*sub;
div = exp(speed);

% DJM
smooth = 24 *SizeRatio; %for the spatial window

% DJM
images = zeros(imsize,imsize,num_frames,'uint8');

% Spatial window parameters
out_rad = (stim_size)/ 2; % let's use the whole screen (rad of about 7.6 deg); before it was 90% of the screen ie out_rad = (stim_size*.9)/ 2;
%in_rad = stim_size/10;

% DJM
in_rad = PPD*0.4; % let's also make the inner radius smaller, 0.4 deg; before it was 1/12th ie : in_rad = stim_size/12 coming to approx 1.2 deg
%this is the same inner annulus as the retinotopy wedge/rings stimuli

% spatial window array to multiply pointwise with stim ...

spat_wind = ones(stim_size);
for (i=1:stim_size)
   for (j=1:stim_size)
      r2 = (i-(stim_size/2))^2 + (j-(stim_size/2))^2;
      if (r2 > out_rad^2) 
          spat_wind(i,j) = 0; 
      elseif (r2 < in_rad^2) 
          spat_wind(i,j) = 0;
          
      % DJM
      elseif (r2 > (out_rad - smooth)^2)
          spat_wind(i,j) = cos(pi.*(sqrt(r2)-out_rad+smooth)/(2*smooth))^2;
      elseif (r2 < (in_rad + smooth)^2)
          spat_wind(i,j) = cos(pi.*(sqrt(r2)-in_rad-smooth)/(2*smooth))^2;
          
      end
   end
end

%apply gaussian envelope to dots:
for i = 1:dot_im_size
    gauss_1d(i) = exp(-(i-(dot_im_size+1)/2)^2/sigma^2);
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
    
    for (i=1:num_dots)
        xrem = rem_pos(i,1);
        yrem = rem_pos(i,2);
        
        xint = int_pos(i,1);
        yint = int_pos(i,2);
        
        % t2 is subsampled image of dot, size (dot_im_size/sub)-1 square ...
        t1 = resample(gauss_2d(sub-xrem:dot_im_size-1-xrem,:),1,sub);
        t2 = resample(t1(:,sub-yrem:dot_im_size-1-yrem)',1,sub);  
        
        % add dot to stimulus array 
        if (pol_mat(i) > 0.5)
            stim = wrap_add(stim,t2,xint,yint,1);
        else
            stim = wrap_add(stim,t2,xint,yint,-1);
        end       
    end
    
    stim = round(stim.*spat_wind.*127 + ones(size(stim)).*128);
    stim = max(min(stim,255),1); % restrict range to 1-255 ...
    
    % DJM
    images(:,:,f) = stim;
end

% DJM

description.genDate = datestr(now);
description.speed = speed_pix;
description.dot_density = dot_density;
description.num_dots = num_dots;
description.num_frames = num_frames;

save('dots_BOLDscreen.mat','images','description');

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
