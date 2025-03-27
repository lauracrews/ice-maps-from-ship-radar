%This script loads the radar images into a matlab array. It was adapted from code provided by Luc Rainville

%Change directory according to if you want images from the first or second
%session

%session = 'First'; %Should be selected in the script calling
%radar_loadImage

% dir_radar_images = ['/Users/lcrews/Documents/MATLAB/SODA/Ice_Radar_Images/', session, 'SessionPhotos'];
dir_radar_images = [pwd, '/', session, 'SessionPhotos'];

disp(['Loading images for the ', lower(session), ' ice radar session'])

files_images = dir([dir_radar_images, '/*.jpg']);

%%%From Luc - select the portion of the image that shows the radar screen

% During HLY1802, all images are 3nm and the screen grab is 1100x1296
Lx = 1100;
Ly = 1296;

% mask origin
iy0 = 542.5;
ix0 = 520.5;

% mask radius (in pixels, = 3nm)
r0 = 471;
M = zeros(1100,1296);
[X,Y]=meshgrid((1:Ly),(1:Lx)');
M( ((X-ix0).^2+(Y-iy0).^2) <= r0^2 ) =1;

ix = find(sum(M,1)>0);
iy = find(sum(M,2)>0);

M_subset = M(iy,ix);

x = (X(1,ix)-ix0)*2*3*1852/length(ix)/1000;  % 3 nautical miles radius in km
y = (Y(iy,1)-iy0)*2*3*1852/length(iy)/1000;  % 3 nautical miles radius in km

clear Lx Ly iy0 ix0 r0 M 

%%% Use image file names to extract metadata (time, lat lon of ship at
%%% image center
load met.mat %Used to cross-reference the image coordinates with the Healy's position to determine image time
for F=1:length(files_images)
    image_name = files_images(F).name;
    
    %Image times in image names are wrong
%     image_times(F) = datenum(image_name(9:25),'yyyymmdd_HH_MM_SS') + (9/24); %Convert local anchorage time to UCT
    
    imageCenter_lats(F) = str2double(image_name((1:3)+26))+str2double(image_name((5:6)+26))/60+str2double(image_name((8:9)+26))/60/60;
    imageCenter_lons(F) =-(str2double(image_name((1:3)+37))+str2double(image_name((5:6)+37))/60+str2double(image_name((8:9)+37))/60/60);
    
    %Takes 0.1 second for each image - slow but not a huge bottleneck (two minutes to process 1000 images)
    %Find the image time by matching the image location to the ship's met data
    %Times are only used for labeling plots - if you are not concerned
    %about this, comment out this code
%     for i = 1:length(met.LA)
%         dists(i) = m_lldist([imageCenter_lons(F), met.LO(i)], [ imageCenter_lats(F), met.LA(i)]);
%     end
%     image_times(F) = met.time(find(dists == min(dists)));
end

% image_times = image_times';
imageCenter_lats = imageCenter_lats';
imageCenter_lons = imageCenter_lons';
imageCenter_lons(imageCenter_lons<0) = imageCenter_lons + 360; %Convert lon to be on 0-360 scale

%%%% Read all images into the 3-dimensional matrix B
F= 1; image_name = files_images(F).name;
A = imread(image_name); % read the image
B=A(iy,ix,:); %Subset of image that actually shows the radar screen
for n=1:size(A,3)
    tmp = B(:,:,n);
    for ii = find(M_subset==0)
        tmp(ii)=uint8(0);
    end
    B(:,:,n)=tmp;
end

clear A F i ii n tmp M_subset X Y x y image_name
  
