% This code is not used - it was adapted into the script radar_loadImage.m

dir_radar_images = '/Volumes/Data_RAID/Data/SODA_data/IceRadarImages/FirstSession/';

files_images = dir([dir_radar_images,'*JPG']);

% During HLY1802, all images are 3nm and the screen grab is 1100x1296
Ly = 1100;
LY = 1296;
% mask origin
iy0 = 542.5;
ix0 = 520.5;
% mash radius (in pixels, = 3nm)
r0 = 471;
M = zeros(1100,1296);
[X,Y]=meshgrid((1:1296),(1:1100)');
M( ((X-ix0).^2+(Y-iy0).^2) <= r0^2 ) =1;

ix = find(sum(M,1)>0);
iy = find(sum(M,2)>0);
M_subset = M(iy,ix);
x = (X(1,ix)-ix0)*2*3*1852/length(ix)/1000;  % 3 nautical miles radius in km
y = (Y(iy,1)-iy0)*2*3*1852/length(iy)/1000;  % 3 nautical miles radius in km

for F=1:length(files_images)
  name = files_images(F).name;
  time(F) = datenum(name(9:25),'yyyymmdd_HH_MM_SS');
  lat(F) = str2double(name((1:3)+26))+str2double(name((5:6)+26))/60+str2double(name((8:9)+26))/60/60;
  lon(F) =-(str2double(name((1:3)+37))+str2double(name((5:6)+37))/60+str2double(name((8:9)+37))/60/60);
  
  % read the image, isolate the return (3nm during SODA). 
  A = imread([dir_radar_images,name]);
  B=A(iy,ix,:);
  for n=1:size(A,3)
    tmp = B(:,:,n);
    for ii = find(M_subset==0)
    tmp(ii)=uint8(0);
    end
    B(:,:,n)=tmp;
  end
  
end
