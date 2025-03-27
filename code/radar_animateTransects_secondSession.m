close all

%First need to run 
% radar_loadImage

%%
%Load uCTD data, match the uCTD casts to the closest radar image to overlay
%the cast locations on the radar image animation
load('uCTD_SODA_v1.mat')
uCTDlons = uCTD.lon'; uCTDlons(uCTDlons < 0) = uCTDlons + 360;
uCTDlats = uCTD.lat';
uCTDtimes = uCTD.time';

uCTDlats = uCTDlats(119:200);
uCTDlons = uCTDlons(119:200);
uCTDtimes = uCTDtimes(119:200);
uCTDids = 119:200;

clear uCTD  minlat minlon

nearestImageIndex = zeros(size(uCTDlats));
for pt = 2:length(uCTDlats) %Start at 2 to skip cast 119
    dists = zeros(size(imageCenter_lats));
    for img = 1:length(imageCenter_lats)
        dists(img) = m_lldist([uCTDlons(pt), imageCenter_lons(img)], [uCTDlats(pt), imageCenter_lats(img)]);
    end
    [dist, ind] = min(dists);
    nearestImageIndex(pt) = ind;
end

%%
cd '/Users/lcrews/Documents/MATLAB/SODA/Ice_Radar_Images/SecondSession_Figures/'
v1 = VideoWriter(['Ice_radar_secondSession.mp4'], 'MPEG-4');
v1.FrameRate = 6; %frames / sec (3 frames / sec => 4 minute video)
v1.Quality = 100;
open(v1)
   
for F = 1:length(files_images)
    close all
    figure(1)
    set(gcf, 'Position', [20 20 1500 800])
    A = imread(files_images(F).name); % read the image
    B=A(iy,ix,:); %Subset of image that actually shows the radar screen

    imshow(B) 
    [w h ~] = size(B); %Dimensions of each image in pixels. In this case, width w = height h
    center = w/2;
    
    text(0, 975, ['Time: ' datestr(image_times(F)), ', Location: ', num2str(imageCenter_lats(F)), ' N, ', num2str(imageCenter_lons(F)), ' W'], 'fontsize', 14)
    hold on
    if ~isempty(find(nearestImageIndex == F))
       ind = find(nearestImageIndex == F);
       scatter(center, center, 50, 'b', 'filled')
       text(center-75, center-30, ['uCTD cast ', num2str(uCTDids(ind))], 'fontsize', 14, 'color', 'b')
    end
    
    F1 = getframe(gcf);
    writeVideo(v1, F1)
end
close(v1)
