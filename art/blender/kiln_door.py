"""Optional separate arched door. Rotate door_hinge around local Y in Godot."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *


def build():
    reset('kiln_door')
    leaf=kiln_door_geometry()
    hinge=empty('door_hinge',(-.565,0,.13))
    # Keep the asset origin at the bottom centre; animate the hinge child instead.
    origin_at(leaf,hinge.location)
    matrix=leaf.matrix_world.copy()
    leaf.parent=hinge
    leaf.matrix_world=matrix
    hinge['open_angle_degrees']=-105
    export('kiln_door')


if __name__=='__main__':
    build()
