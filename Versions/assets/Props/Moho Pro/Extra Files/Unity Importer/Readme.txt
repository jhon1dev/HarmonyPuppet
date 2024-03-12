Anime Studio Pro can export FBX files for use in various 3D programs. One of the primary
applications we expect users to use is Unity, the game authoring tool: https://unity3d.com/

Unity can import Anime Studio's exported FBX files directly, but when importing FBX, Unity
generally expects them to be 3D files (3D geometry, polygons, faces, shading, etc.).
Anime Studio's FBX files are a little different, in that Anime characters typically
consist of flat 2D artwork.

So, we created an import script that can be used with Unity. This script "cleans up" Anime
Studio content that you bring into Unity. It does the following:

* Anime Studio layers, if not arranged in 3D, come into Unity all "smashed together". Unity
can have trouble drawing these layers in the correct order. The import script tells Unity
what order to draw Anime Studio layers in to get the result to look as it did in Anime Studio.

* Anime Studio doesn't have a lighting model for 2D layers. Unity wants to shade all
objects by default. The import script adjusts the shader used on Anime Studio objects so
that they appear unlit and are double-sided so that they don't become invisible if they
rotate or flip around.

* Unity doesn't support animated object visibility in FBX files. So, to support visibility,
Anime Studio scales objects down very tiny to make them invisible, and then back up to
normal to show them again. When importing this, Unity would introduce an unwanted "bounce"
on the objects as they went from invisible to visible and back. The import script fixes this.

How to use the import script:

Find your Unity project folder on disk. Let's say it's here:

/Users/AnimeUser/UnityProject/

First, make sure you have two more sub-folders, like so (they may already exist):

/Users/AnimeUser/UnityProject/Assets/Editor/

Next, copy the AnimeStudioFBXImporter.cs import script from this folder into the Editor
folder above.

That's it! Once the import script is in place, whenever you import an FBX file from Anime
Studio, it will get processed and cleaned up for use in Unity.

Finally, here's a little video that shows a bit about importing FBX files into Unity:

https://youtu.be/oz91ZIQMjpo
