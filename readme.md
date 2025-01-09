Adds a command to create custom cutscenes.
- Use `/cutscene` and shift-click anywhere on the map to specify waypoints. Additional settings for transition time, waiting time, and zoom can be adjusted in mod settings.
- Use `/end-cutscene` to end a cutscene early and immediately return control to the player.

Shift-click on trains and train stations to add them as waypoints too!

Create a cutscene to watch trains, get a birds-eye view of the factory, scout for biters, or whatever you want! GUI is hidden during cutscene, making this a great tool for creating factory/map showcase videos :)


------------------
Advanced features:

Unless otherwise specified, cutscene creator will use the values set in player mod settings for transition time, waiting time, and zoom for each waypoint.

To manually set those values for a given waypoint, simply add the following tags with the values you want after the waypoint:

     tt <value>      - transition time (number of ticks it takes to get to the waypoint)
     wt <value>      - waiting time (number of ticks to wait at the waypoint before going to the next one)
     z <value>       - zoom (the zoom value when arriving at the waypoint)

![example command image](https://github.com/jingleheimer-schmidt/imgs/raw/primary/cutscene_creator_command_example.png)

`/cutscene [gps=170,142] tt360 wt60  [gps=173,132] [train=628270] tt180 wt600 z0.3 [train-stop=274328]`

In the example command pictured above, first the camera will travel from the current player position to 170,142, taking 360 ticks (6 seconds) to travel that distance. It will then wait at 170,142 for 60 ticks (1 second) before beginning to move to the next waypoint. 

Because the next waypoint (173,132) does not have any tags after it, cutscene creator will use the values saved in player mod settings to determine transition time, waiting time, and zoom for that waypoint. 

The camera will then take 180 ticks (3 seconds) to travel to the next waypoint, train 217. Because z is specified as 0.3 for this waypoint, the camera will zoom in or out until it reaches that level, depending on what zoom value the previous waypoint had (in this case it was determined by player mod settings). 

After waiting for 10 seconds at the train, the camera will begin moving to the next waypoint, train station "Bilka". This train station waypoint does not have any tags specified, so cutscene creator will again just use the values from player mod settings.  

------------------

Tips and tricks: 
- The tags must come after the waypoint you want them to affect
- If any tags are present, then both tt and wt are mandatory
- If tt and wt are present but z is not, the zoom for that waypoint will be the same as the previous waypoint
- If no tags are present, cutscene creator will use the values set in player mod settings for all three
- All " " (space) characters between tags, tag values, and waypoints are purely cosmetic (read: optional) and will have no effect on the created cutscene
- It is suggested to open the map view before opening the console to type the command, since you can click and drag the map under the console input to find locations for waypoints that are far away (especially useful when adding trains)
- If a double-headed train is given as a waypoint, cutscene creator will focus on what factorio internally determines to be the "front" locomotive (typically the first locomotive that was built for that train). Due to limitations with cutscenes and how "front"/"back" locomotives are determined, this means sometimes the locomotive in focus will actually be the one on the back of the train. If you would like cutscene creator to do better job at determining which locomotive is leading the train, please post on the discussion board and I will look into it further.
- If you have any feature requests post them on the discussion board! 
