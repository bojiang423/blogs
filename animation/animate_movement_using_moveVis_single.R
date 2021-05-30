#########################################################################################################
# This script is an example to use moveVis package to create animation for movement data 
# For more about moveVis package, refer to http://movevis.org/
#########################################################################################################
library(moveVis)

# Read csv data into a dataframe 
# This data was downloaded from movebank, https://www.movebank.org/cms/movebank-main
# The original study is "South American Coati, Nasua nasua, Argentina, Hirsch Ph.D. work"
df_songbirds <- read.table("coati.csv", sep=",", header=T)

# convert timestamp to POSIXct 
data_4_gif$timestamp = as.POSIXct(data_4_gif$timestamp, format="%Y-%m-%d %H:%M:%OS", tz="UTC")

# convert dataframe into move object 
# For more about move package, check https://bartk.gitlab.io/move/
data_move <- df2move(data_4_gif,
                     proj = "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                     time="timestamp", 
                     x = "location.long", y = "location.lat", 
                     track_id = "individual.local.identifier")

# the interval between 2 frames is 30m
data_move_30m <- align_move(data_move, res=5, unit="mins")

# creates a list of ggplot2 maps displaying movement
frames <- frames_spatial(data_move_30m, path_colours = c("red"),
                         map_service = "osm", map_type = "streets", 
                         equidistant = F, trace_show=T, trace_colour="white") %>%
  add_labels(x = "location.long", y = "location.lat") %>% 
  add_northarrow(position="upperright") %>% 
  add_scalebar(position="bottomleft") %>%   
  add_timestamps(data_move_30m, type = "label") %>%
  add_progress(colour="red", size=4) 

# check one of the frames 
frames[[100]]

# export the frames into gif or other supported formats
animate_frames(frames, 
               out_file = "coati.gif",  # use suggest_formats() to get supported file formats, eg. mp4, mov
               fps=25,
               overwrite = T)

