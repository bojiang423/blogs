#########################################################################################################
# This script is an example to use moveVis package to create animation for movement data 
# For more about moveVis package, refer to http://movevis.org/
#########################################################################################################
library(moveVis)

# Read csv data into a dataframe 
# This data was downloaded from movebank, https://www.movebank.org/cms/movebank-main
# The original study is "Space use and activity of a major songbird nest predator in a tropical Thailand forest, Boiga cyanea"
df_songbirds <- read.table("songbirds.csv", sep=",", header=T)

# convert timestamp to POSIXct 
df_songbirds$timestamp = as.POSIXct(df_songbirds$timestamp, format="%Y-%m-%d %H:%M:%OS", tz="UTC")

# get number of unique objects in this dataframe
no_of_objs = length(unique(df_songbirds$individual.local.identifier))

# convert dataframe into move object 
# For more about move package, check https://bartk.gitlab.io/move/
move_songbirds <- df2move(df_songbirds,
                     proj = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                     time="timestamp", 
                     x = "location.long", y = "location.lat", 
                     track_id = "individual.local.identifier")

# the interval between 2 frames is 24 hours 
# this is based on the original data
# reduce the interval will increase number of frames, as well as the time spend on exporting the animation
move_songbirds_4h <- align_move(move_songbirds, res=24, unit="hours")

# creates a list of ggplot2 maps displaying movement
frames <- frames_spatial(move_songbirds_4h, path_colours = randomColor(no_of_objs),
                         map_service = "osm", map_type = "streets", 
                         equidistant = F, trace_show=F, trace_colour="white") %>%
  add_labels(x = "location.long", y = "location.lat") %>% 
  add_northarrow(position="upperright") %>% 
  add_scalebar(position="bottomleft") %>%   
  add_timestamps(move_songbirds_4h, type = "label") %>%
  add_progress(colour="red", size=4) 

# check one of the frames 
frames[[100]]

# export the frames into gif or other supported formats
animate_frames(frames, 
               out_file = "songbirds.gif",  # use suggest_formats() to get supported file formats, eg. mp4, mov
               fps=25,
               overwrite = T)

