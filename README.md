# Godot4Net
This is a godot 4 project implementing high-level multiplayer networking. \
Server and client are separated into two projects and its 3D thirdperson.

Any help is appreciated <3

<img src="screenshot.png" width="100%" height="100%">

## Headless server mode
you can run the server headless
```bash
godot --display-driver headless --path git/Godot4Net/server/
```

## Additional info
Atm there is an issue. I want to sync some vars reliable and some unreliable. For example position should be unreliable udp but MultiplayerSynchronizer doesnt seem to give me the possibility to set sync vars to transfermode unreliable.

So for now everything is reliable. I might do the vars i want to sync unreliable with rpc funcs.

Am also thinking about low-level approach and im currently trying stuff at weekends. Maybe a low-level implementation will be ready in the next months. Gives me more Freedom ;)

## Todo list
* unreliable sync
* change_map func
* chat
* on server remove textures etc.
* decouple code with signals
* instancing grass, trees, stones (either via particle or multimesh or shader?)
* create new world, add more assets
* player with custom bones, (mixamo? whats the license?) animations and root motion 

## Tested on

<a href="https://ubuntu.com">
  Ubuntu 25.04 (plucky)
</a>

## Built With

<a href="https://godotengine.org/">
    <img src="https://godotengine.org/assets/press/icon_color.svg" width="32" height="32" style="vertical-align:middle">
    Godot_v4.4.1-stable_linux.x86_64
</a>
