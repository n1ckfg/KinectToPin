@echo off

set BUILD_TARGET=kinect_to_pin.py
cd %cd%

rem del %BUILD_TARGET%

rem copy /b latk_main.py+latk_tools.py+latk_rw.py+latk_mtl.py+latk_mesh.py+latk_draw.py+latk_freestyle.py+latk_shortcuts.py+latk_ui.py+latk_tilt.py %BUILD_TARGET%

copy %BUILD_TARGET% "%homepath%\AppData\Roaming\Blender Foundation\Blender\2.77\scripts\addons"
copy %BUILD_TARGET% "%homepath%\AppData\Roaming\Blender Foundation\Blender\2.78\scripts\addons"
copy %BUILD_TARGET% "%homepath%\AppData\Roaming\Blender Foundation\Blender\2.79\scripts\addons"
copy %BUILD_TARGET% "%homepath%\AppData\Roaming\Blender Foundation\Blender\2.80\scripts\addons"
@pause