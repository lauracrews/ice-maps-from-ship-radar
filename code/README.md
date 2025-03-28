## Overview

This code processes ship's radar images collected on the 2018 Stratified Ocean Dynamics of the Arctic cruise (HLY1802) concurrent with underway CTD sampling. The produced figures also show the locations of uCTD casts. The uCTD data is copied into the directory 'uCTD'.

There were two “sessions” of transects. The first session consisted of back-and-forth transects in marginal ice conditions. Animations of radar images along each transect are available [here](https://drive.google.com/drive/folders/1orwtpSAoUxuq2yCoRCUehnPyko8aJfpc?usp=drive_link). The second session had a lot of blowing snow or other contamination so was not useful for mapping ice conditions – this can be seen by reviewing the animation [Ice_radar_secondSession.mp4](https://drive.google.com/file/d/1XhwLskGBNy0pxP8PrhaxzaLudtAeaxaQ/view?usp=drive_link).

Directories containing the photos of the radar screen from which the maps can be downloaded from [here](https://drive.google.com/drive/folders/1WPJR5JkLdMTmpazkbPyDFuCxHcOFSyVb?usp=drive_link) (first sesssion) and [here](https://drive.google.com/drive/folders/1HhrKUJ9u2-QCaL8KBZ-bWemg_db63spe?usp=drive_link) (second session). 

## Code descriptions

`radar_loadImage.m` must be run first. It loads the radar images into a MATLAB array. It contains information about the screen grab size and converts pixel coordinates to xy coordinates, then subsets the full screen grab to the portion of the images that actually shows the radar screen. It also extracts the lat/lon coordinates of the image centers (ship’s location) from the image file names. 

`radar_plotImages_makeMap.m` is the primary scrip for making the geolocated maps combining all of the radar images. It iterates through all the images and takes a slice from each image to be stitched together into the composite. It then calculates the coordinates of each pixel in the image by finding a range and bearing from the image center.

Animations of both sessions are made with `radar_animateTransects_firstSession.m` and `radar_animateTransects_secondSession.m`. These animations include the cropped radar images, time, ship’s location, and locations of uCTD casts. 
