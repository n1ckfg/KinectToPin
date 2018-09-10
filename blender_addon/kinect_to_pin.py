bl_info = {
    "name": "KinectToPin mocap", 
    "author": "Nick Fox-Gieg",
    "description": "Import and export K2P xml format",
    "category": "Animation"
}

import bpy
from bpy.types import Operator, AddonPreferences
from bpy.props import (BoolProperty, FloatProperty, StringProperty, IntProperty, PointerProperty, EnumProperty)
from bpy_extras.io_utils import (ImportHelper, ExportHelper)
import xml.etree.ElementTree as etree

def readKinectToPin(filepath=None, resizeTimeline=True):
    tree = etree.parse(filepath)
    root = tree.getroot()
    fps = getSceneFps()
    start, end = getStartEnd()
    #~
    MotionCapture = root.find("MotionCapture")

def writeKinectToPin(filepath=None, bake=False):
    pass

class ImportK2P(bpy.types.Operator, ImportHelper):
    """Load a KinectToPin xml File"""
    resizeTimeline = BoolProperty(name="Resize Timeline", description="Set in and out points", default=True)

    bl_idname = "import_scene.k2p"
    bl_label = "Import K2P"
    bl_options = {'PRESET', 'UNDO'}

    filename_ext = ".xml"
    filter_glob = StringProperty(
            default="*.xml",
            options={'HIDDEN'},
            )

    def execute(self, context):
        import kinect_to_pin as k2p
        keywords = self.as_keywords(ignore=("axis_forward", "axis_up", "filter_glob", "split_mode", "resizeTimeline"))
        if bpy.data.is_saved and context.user_preferences.filepaths.use_relative_paths:
            import os
        #~
        keywords["resizeTimeline"] = self.resizeTimeline
        k2p.readKinectToPin(**keywords)
        return {'FINISHED'}

class ExportK2P(bpy.types.Operator, ExportHelper): # TODO combine into one class
    """Save a KinectToPin xml File"""

    bake = BoolProperty(name="Bake Frames", description="Bake Keyframes to All Frames", default=False)

    bl_idname = "export_scene.k2p"
    bl_label = 'Export K2P'
    bl_options = {'PRESET'}

    filename_ext = ".xml"

    filter_glob = StringProperty(
            default="*.xml",
            options={'HIDDEN'},
            )

    def execute(self, context):
        import kinect_to_pin as k2p
        keywords = self.as_keywords(ignore=("axis_forward", "axis_up", "filter_glob", "split_mode", "check_existing", "bake"))
        if bpy.data.is_saved and context.user_preferences.filepaths.use_relative_paths:
            import os
        #~
        keywords["bake"] = self.bake
        #~
        k2p.writeKinectToPin(**keywords, zipped=False)
        return {'FINISHED'}

def menu_func_import(self, context):
    self.layout.operator(ImportK2P.bl_idname, text="KinectToPin mocap (.xml)")

def menu_func_export(self, context):
    self.layout.operator(ExportK2P.bl_idname, text="KinectToPin mocap (.xml)")

def register():
    bpy.utils.register_module(__name__)

    bpy.types.INFO_MT_file_import.append(menu_func_import)
    #bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_module(__name__)

    bpy.types.INFO_MT_file_import.remove(menu_func_import)
    #bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()
