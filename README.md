![alt tag](logo.png)

# Murasaki
An Attempt to write my own Browser Engine in D!
it sounds stupid, but i actually began writing it
so... you're too late to stop me now.

Of course, currently it only supports parsing, but in the future i'll try to code my own
javascript engine which is definitally going to be something extra hard.

i want to reach a point in which i can at least open a github page on it.

the UI of this thing is planned to be made nativaly with OpenGL.

# Building from Source
First, you'll need GLFW version 3.3 or higher.
if you're on windows you can simply throw it in `lib/`

to build it simply use `node build.js`
by the way, if you want to use a custom D compiler,
use `node build.js /use:<compilername>`

Currently i've only tested this project in windows,
if you find any bugs on other operating systems
please report it as a Issue. on the issues page.

# Libraries in use
(OpenGL Binding) https://github.com/BindBC/bindbc-opengl
(GLFW Binding)   https://github.com/BindBC/bindbc-glfw
(GLFW) https://www.glfw.org/