[![Ko-fi Donate](https://img.shields.io/badge/Ko--fi-Donate%20-indianred?logo=kofi&logoColor=white)](https://ko-fi.com/asher_sky) [![GitHub Contribute](https://img.shields.io/badge/GitHub-Contribute-blue?logo=github)](https://github.com/jingleheimer-schmidt/spiderbots) [![Crowdin Translate](https://img.shields.io/badge/Crowdin-Translate-green?logo=crowdin)](https://crowdin.com/project/factorio-mods-localization) [![Mod Portal Download](https://img.shields.io/badge/Mod_Portal-Download-orange?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAMAAACecocUAAABhGlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV9bS4tUHewg4hCwOlkQFXHUKhShQqgVWnUwufQLmjQkKS6OgmvBwY/FqoOLs64OroIg+AHi4uqk6CIl/i8ptIjx4Lgf7+497t4B/kaFqWbXOKBqlpFOJoRsblUIvSKMIHoxjJjETH1OFFPwHF/38PH1Ls6zvM/9OXqUvMkAn0A8y3TDIt4gnt60dM77xFFWkhTic+Ixgy5I/Mh12eU3zkWH/TwzamTS88RRYqHYwXIHs5KhEk8RxxRVo3x/1mWF8xZntVJjrXvyF0by2soy12kOIYlFLEGEABk1lFGBhTitGikm0rSf8PAPOn6RXDK5ymDkWEAVKiTHD/4Hv7s1C5MTblIkAQRfbPtjBAjtAs26bX8f23bzBAg8A1da219tADOfpNfbWuwI6NsGLq7bmrwHXO4AA0+6ZEiOFKDpLxSA9zP6phzQfwt0r7m9tfZx+gBkqKvUDXBwCIwWKXvd493hzt7+PdPq7wdcTnKeyn2biAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+MIBQ4nOKPzX44AAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAAnFBMVEUAAAAAAAAAAAAAAABBPj5EQ0NBQUFCQkJYV1daWlpcXFxfXl19enl7enp6enp9fX2Rjo2Ojo6RkZGUk5OfnJufn5+goKCioqK5uLe3t7e5ubm6urrPz8/Pz8/R0NDT0tHT09PV1dXW1tXh4ODh4eHg4ODh4eHi4eHi4uLi4uLi4uLk4+Pk5OTl5eXm5ubm5ubn5ubn5+fp6en+/vsJa+h2AAAAMnRSTlMAAgMEEBIUFR0jJSY8PUBDU1daX2hucHOTlpicxcbIyc7R0unq6+vt7e7v8vT2+Pn6+p+as4UAAAABYktHRDM31XxeAAAAYUlEQVQIHQXBBQLCQBDAwJTF3b0Uh2IH+f/jmAGA5yYygG65OFpOOoMMmqrqJWCoaZt0FizPpnpUP+6Dh+YR5PqGwtSIWvK6gqn+dl8dBZxU1VZArz2+eZjf+xkA61dUgD8jzgwslUkzIwAAAABJRU5ErkJggg==)](https://mods.factorio.com/mod/spiderbots)

# Overview

Adds a command to create custom cutscenes.
- Use `/cutscene` and shift-click anywhere on the map to specify waypoints (positions, trains, or train stops) for the cutscene.
- Default values for transition time, waiting time, and zoom can be adjusted in mod settings.
- Use `/end-cutscene` or tab (open-map) to end a cutscene early and immediately return control to the player.

---------------------
# Advanced Features

Unless otherwise specified, cutscene creator will use the values set in player mod settings for transition time, waiting time, and zoom for each waypoint.

To manually set those values for a given waypoint, add tags with the values you want after the waypoint:

`transition <value>`  - The number of seconds it takes to get to the waypoint
`wait <value>`        - The number of ticks to wait at the waypoint before going to the next one
`zoom <value>`        - The zoom level when arriving at the waypoint

You can also use shorthand for the tags: `t`, `w`, and `z`

![example command image](https://github.com/jingleheimer-schmidt/imgs/raw/primary/cutscene_creator_command_example.png)

`/cutscene [gps=340.4,-75.4] transition 15 wait 10 [train=628270] t10 [train-stop=274328] z.3, t 5, wait 15`

In the example command pictured above, first the camera will take 15 seconds to travel from the current player position to 340, -75. It will then wait 10 seconds before beginning to move to the next waypoint. 

Because the next waypoint (Train 217) has the shorthand transition tag `t10`, the camera will take 10 seconds to get there. Since no other tags are specified, cutscene creator will use the default values for wait time and zoom level, which are set in player mod settings.

The next waypoint is a train stop, "Bilka". The camera will take 5 seconds to get there, zooming out so that the zoom level is 0.3 when it gets to the waypoint. It will then wait for 15 seconds before returning to the starting position.

------------------
# Tips and Tricks

- The tags must come after the waypoint you want them to affect
- All tags are optional and can be used in any combination or order
- If any tag is not present, cutscene creator will use the value set in player mod settings
- Try opening the map before opening the console to type the command; you can click and drag the map under the console input to find locations for waypoints that are far away (especially useful when adding trains)
- Please report any issues or feature requests on the Discussion page
