%% This script makes a composite map of the ice radar images taken during the Healy 1802 cruise.
% It iterates through all the images and takes a slice from each image to
% be stitched together into the composite. It then calculates the
% coordinates of each pixel in the image by finding a range and bearing from
% the image center

%%
close all
save_plots = false; 
session = 'First'; %Choose 'First' or 'Second'
radar_loadImage

savedir = ['/Users/lcrews/Documents/MATLAB/SODA/Ice_Radar_Images/', session, 'Session_Figures'];


load(['transectStart_imageNames_', lower(session), 'Session.mat'])

%% Load uCTD data, used to overlay profile locations
load('uCTD_SODA_v1.mat')
uCTDlons = uCTD.lon'; uCTDlons(uCTDlons < 0) = uCTDlons + 360;
uCTDlats = uCTD.lat';
uCTDtimes = uCTD.time';
clear uCTD

load uCTD_transectStart.mat
load goodProfiles.mat

%% Identify the image at the start of each transect
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
clear transectNum

%% Calculate information about the size of each image, used for plotting later

A = imread(files_images(1).name); % read the image
A=A(iy,ix,:); %Subset of image trimmed to exactly fit the outside of the radar screen. iy and ix are from radar_loadImage     
A = double(rgb2gray(A)); %Convert to a 2D matrix

%%% Calculate dimensions needed to project lat lon of images
[Ah Aw] = size(A); %Dimensions of each image in pixels. In this case, width w = height h
center_Ah = ceil(Ah/2); center_Aw = ceil(Aw/2);

screenDiam = 6; screenDiam = screenDiam * 1852; %Since the radar screen has a known diameter of 6 nautical miles, here converted to m
m_per_pixel = screenDiam / Aw; %Effective width of each pixel in m

%Calculate distance and bearing from center pixel for other pixels in the image 
distFromCenter = nan .* ones(size(A));
bearing = nan .* ones(size(A));
for i = 1:Ah
    for j = 1:Aw
        distFromCenter(i, j) = sqrt((i-center_Ah)^2 + (j-center_Aw)^2) * m_per_pixel;
        bearing(i, j) = atan2d(j-center_Ah, center_Aw-i);
    end
end
bearing = abs(bearing - 180);

%Can confirm calculation with pcolor(bearing), pcolor(distFromCenter)

%%
%Iterate through all transects and make a separate composite map for each
%transect

%Use transect 1:9 for session 1
%Use transect 1:2 for session 2

if strcmp(session, 'First')
    transects = 1:9;
elseif strcmp(session, 'Second')
    transects = 1:2;
end

for transect = transects
%%
    disp(['Plotting map for transect ', num2str(transect )])

    lons_thisTransect = imageCenter_lons(transectStart_index(transect):1:transectStart_index(transect + 1) - 1);
    lats_thisTransect = imageCenter_lats(transectStart_index(transect):1:transectStart_index(transect + 1) - 1);

    minlon = min(lons_thisTransect(:)) - .03; maxlon = max(lons_thisTransect(:)) + .05;
    minlat = min(lats_thisTransect(:)) - 0.03; maxlat = max(lats_thisTransect(:)) + 0.03;
    m_proj('lambert', 'lon', [minlon maxlon], 'lat', [minlat maxlat]);

    [X_imageCenter, Y_imageCenter] = m_ll2xy(imageCenter_lons, imageCenter_lats); %Projection must be set up before this will work

    figure(transect)
    set(gcf, 'Position', [20 20 1000 1000])
    
%     set(gcf, 'Position', [20 20 1500 1000])
%     subplot(1, 2, 1)
    
    %Iterate through each image in the transect and overlay subset of each image onto a base map
    for F=transectStart_index(transect):transectStart_index(transect + 1) - 1 
        
        A = imread(files_images(F).name); % read the image
        A = A(iy,ix,:); %Subset of image trimmed to exactly fit the outside of the radar screen
        A = double(rgb2gray(A)); 
        A = flipud(A); %Necessary when going from matlab image format to matrix. Confirm by doing imshow(A) after intially loading and comparing to pcolor(A) after flipping
         
        %Fnd the distance to the center of the next image that will be
        %used. Determines how wide the slice of the current image should be
        %so that it will line up with the next image. 
        dist2next = 1000 * m_lldist([imageCenter_lons(F), imageCenter_lons(F + 1)], [imageCenter_lats(F), imageCenter_lats(F+1)]); %Convert km to m
        pixels2next = ceil(dist2next / m_per_pixel) + 2;       
        
        %This determines which slice of the image is used to make the
        %composite. The subset selected depends on if the ship is traveling
        %left-righ or right-left (if first session) or if the ship is
        %trvalling E-W or N-S (second session). Image is subset such that
        %pixels are taken from behind the ship (it is not centered on the
        %ship itself). This is because of blank spot in image right under
        %the ship
        if strcmp(session, 'First')
            iy2 = center_Ah - 200:center_Ah + 200;
            if isodd(transect)        
                ix2 = center_Aw + 17:center_Aw + 17 + pixels2next;
            else
                ix2 = center_Aw - 17 - pixels2next:center_Aw - 17;
            end
        elseif strcmp(session, 'Second')
            if transect == 1 %Transect is oriented more or less E-W
                iy2 = center_Ah - 200:center_Ah + 200;
                ix2 = center_Aw + 17:center_Aw + 17 + pixels2next;
            elseif transect == 2 %Transect is oriented more or less N-S     
                ix2 = center_Aw - 200:center_Aw + 200;
                iy2 = center_Aw - 17 - pixels2next:center_Aw - 17;
            end
        end

        %Take subset of the image as well as range and bearing
        B = A(iy2, ix2, :);
        B_bearing = bearing(iy2, ix2);
        B_distFromCenter = distFromCenter(iy2, ix2);

        [Bh Bw] = size(B); 
        center_Bh = ceil(Bh/2); center_Bw = ceil(Bw/2);

        %Calculate lat lon coordinates of each pixel in the image
        lons_curImage = nan .* ones(size(B));
        lats_curImage = nan .* ones(size(B));
            
        %Iterate through each pixel within the threshold distance, calculate
        %its position using its bearing and distance from the center
        for i = 1:Bh
            for j = 1:Bw
                [lon2, lat2, ~] = m_fdist(imageCenter_lons(F), imageCenter_lats(F), B_bearing(i, j), B_distFromCenter(i, j));
                lons_curImage(i, j) = lon2; 
                lats_curImage(i, j) = lat2;
            end
        end    
       
        %% Add the current image to the growing map
        m_pcolor(lons_curImage, lats_curImage, B)
        shading flat
        colormap gray 
        hold on
    end %End of the loop adding more images to the map

    %Select which uCTD profile locations to add to the map
    [X_uctd, Y_uctd] = m_ll2xy(uCTDlons, uCTDlats);
    if strcmp(session, 'First')
        ii = uCTD_transectStart(transect + 6):uCTD_transectStart(transect + 7) - 1;
        textRotation = 45;
    elseif strcmp(session, 'Second')
         if transect == 1
             ii = uCTD_transectStart(16):uCTD_transectStart(18) - 1;
             textRotation = 45;
         else
             ii =  uCTD_transectStart(18):uCTD_transectStart(19) - 1;
             textRotation = 0;
         end
    end
    
     for i = ii
        if ismember(i, goodProfiles)
            h(1) = scatter(X_uctd(i), Y_uctd(i), 20, 'b', 'filled');
            text(X_uctd(i), Y_uctd(i), ['  ', num2str(i)], 'color', 'w', 'fontsize', 10, 'rotation', textRotation)
        else
            h(2) = scatter(X_uctd(i), Y_uctd(i), 20, 'r', 'filled');
            text(X_uctd(i), Y_uctd(i), ['  ', num2str(i)], 'color', 'w', 'fontsize', 10, 'rotation', textRotation)
        end
     end
    
    
    m_grid('fontsize', 14, 'linestyle', 'none')
    
    if strcmp(session, 'First')
        lgd = legend(h(1:2), 'Profiles with Temperature and Salinity', 'Profiles with Only Temperature');
        set(lgd, 'location', 'southoutside', 'fontsize', 11)
        title(lgd, "Ice Conditions from Ship's Radar", 'fontsize', 12)
    end

    %% Save the image
    if save_plots
        cd(savedir)
        savename = ['Transect_', num2str(transect), '.png'];
        saveas(gcf, savename)
        
        savename = ['Transect_', num2str(transect),'.fig'];
        saveas(gcf, savename)
    end

end

% clear A F name curlon curlat lons_curImage transect lats_curImage i j center screenDiam  m_per_pixel bearing distFromCenter lat2 lon2 dist2next pixels2next dist2shift pixels2shift
% clear B_full B_full_prev curImg_vertCenter_edge_lat curImg_vertCenter_edge_lat latOffset ix2_prev ix2 lats_prevImage lons_prevImage prevImg_vertCenter_edge_lat prevImg_vertCenter_edge_lon X_cur Y_cur
