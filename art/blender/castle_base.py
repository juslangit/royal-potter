"""Seven flat tower sockets inside a low cream curtain wall; no baked towers."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *

# Blender XY positions; positive Y is the back (negative Z after glTF export).
SOCKETS=[(-2.22,.85,2.0),(0,.85,2.4),(2.22,.85,2.0),
         (-1.12,.12,1.6),(1.12,.12,1.6),(-2.12,-.80,1.2),(2.12,-.80,1.2)]


def build():
    reset('castle_base')
    box('courtyard_plinth',(0,0,.065),(6.15,3.15,.13),CREAM,bevel=.055)
    # Walls share a ground reference; socket tops are at .16.
    wall('wall_back',(-3,1.5,0),(3,1.5,0))
    wall('wall_left',(-3,-1.5,0),(-3,1.5,0))
    wall('wall_right',(3,1.5,0),(3,-1.5,0))
    wall('wall_front_left',(-3,-1.5,0),(-.58,-1.5,0))
    wall('wall_front_right',(.58,-1.5,0),(3,-1.5,0))
    arch_shape('wooden_gate',0,-1.50,.13,.54,.56,.14,OAK)
    arch_frame('gate_arch',0,-1.50,.13,.55,.56,.14,.29,CREAM)
    for x in (-.30,0,.30):
        box('gate_plank_'+str(x),(x,-1.576,.40),(.017,.016,.51),INK)
    for x in (-.12,.12):
        ellipsoid('gate_handle_'+str(x),(x,-1.61,.47),(.035,.035,.07),GOLD,8,4)
    for i,(x,y,recommended_height) in enumerate(SOCKETS,1):
        disc(f'socket_disc_{i}',(x,y,.13),.60,.03,SAGE,20)
        marker=empty(f'socket_{i}',(x,y,.16))
        marker['suggested_tower_height']=recommended_height
        marker['radius']=.6
    export('castle_base')


if __name__=='__main__':
    build()
