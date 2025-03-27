close all
%First need to run 
radar_loadImage

%%
%Load uCTD data, match the uCTD casts to the closest radar image to overlay
%the cast locations on the radar image animation
load('uCTD_SODA_v1.mat')
uCTDlons = uCTD.lon'; uCTDlons(uCTDlons < 0) = uCTDlons + 360;
uCTDlats = uCTD.lat';
uCTDtimes = uCTD.time';
uCTDids = 1:length(uCTDlats);
inTimeMask = ones(size(uCTDtimes));
inTimeMask(uCTDtimes > max(image_times(:))) = 0; inTimeMask(uCTDtimes < min(image_times(:))) = 0; 
uCTDlats = uCTDlats(inTimeMask == 1); uCTDlons = uCTDlons(inTimeMask == 1); uCTDtimes = uCTDtimes(inTimeMask == 1); uCTDids = uCTDids(inTimeMask == 1);

clear uCTD inTimeMask minlat minlon

if length(files_images) ~= length(imageCenter_lats)
    disp('not all image centers included')
end

nearestImageIndex = zeros(size(uCTDlats));
for pt = 1:length(uCTDlats)
    dists = zeros(size(imageCenter_lats));
    for img = 1:length(imageCenter_lats)
        dists(img) = m_lldist([uCTDlons(pt), imageCenter_lons(img)], [uCTDlats(pt), imageCenter_lats(img)]);
    end
    [dist, ind] = min(dists);
    nearestImageIndex(pt) = ind;
end
%%
%Find the image index of each image at the beginning of a transect
load transectStart_imageNames_firstSession.mat %Have manually identified which image comes at the start of each transect
transectStart_index = nan .* ones(size(transectStarts_imageNames));
transectNum = 1;
for F = 1:length(files_images)
    if strcmp(transectStarts_imageNames(transectNum), files_images(F).name)
        transectStart_index(transectNum) = F;
        transectNum = transectNum + 1;
    end

    if transectNum == length(transectStart_index) + 1
        break
    end
end
%%

%Make a new video for each transect
for transect = 1:length(transectStart_index) - 2
    v1 = VideoWriter(['Ice_radar_transect', num2str(transect), '.mp4'], 'MPEG-4');
    v1.FrameRate = 6; %frames / sec (3 frames / sec => 4 minute video)
    v1.Quality = 100;
    open(v1)

    for F=transectStart_index(transect):transectStart_index(transect + 1) - 1
        close all
        figure(1)
        set(gcf, 'Position', [20 20 1500 800])
       
        A = imread(files_images(F).name); % read the image
        B=A(iy,ix,:); %Subset of image that actually shows the radar screen

        imshow(B) 
        text(0, 975, ['Time: ', datestr(image_times(F)), ' Location: ', num2str(imageCenter_lats(F)), ' N, ', num2str(imageCenter_lons(F)), ' W'], 'fontsize', 14)
        hold on
        
        if ~isempty(find(nearestImageIndex == F)) %This is the nearest image to one of the uCTD casts
           ind = find(nearestImageIndex == F);
           scatter(center, center, 50, 'b', 'filled')
           text(center-75, center-30, ['uCTD cast ', num2str(uCTDids(ind))], 'fontsize', 14, 'color', 'w')
        end
        F1 = getframe(gcf);
        writeVideo(v1, F1)
    end
    close(v1)

end
    
clear A F name ind curlon curlat lons_curImage transect lats_curImage i j center screenDiam  m_per_pixel bearing distFromCenter lat2 lon2 

