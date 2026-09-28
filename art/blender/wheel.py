"""Build the low-poly wheel. Blender Z=0 is the wheelhead TOP, by brief."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *


def build():
    reset('wheel')
    # Cream is the palette's pale stone colour; no extra grey material.
    lathe('wheel_head',[(.88,-.14),(.95,-.115),(.95,-.025),(.92,0)],
          CREAM,n=24)
    disc('wheel_axle',(0,0,-.73),.16,.59,INK,12)
    lathe('wheel_body',[(.60,-1.10),(.66,-1.02),(.67,-.60),(.81,-.47)],
          OAK,n=16)
    # Cross-section folds inward: an actual open annular splash tray.
    lathe('splash_tray',[(.82,-.48),(1.19,-.48),(1.27,-.39),
                       (1.27,-.12),(1.20,-.08),(1.12,-.12),
                       (1.12,-.35),(.82,-.35),(.82,-.48)],
          OAK,n=24,cap=False)
    # Wide stave seams stop below the tray rather than covering the stone head.
    for i in range(12):
        a=2*math.pi*i/12
        seam=box(f'body_stave_{i+1:02d}',
                 (.659*math.cos(a),.659*math.sin(a),-.81),
                 (.018,.026,.36),INK)
        seam.rotation_euler.z=a
    for z in (-1.015,-.61):
        lathe('body_band_'+str(abs(z)),[(.669,z),(.669,z+.045)],INK,16,cap=False)
    export('wheel')


if __name__=='__main__':
    build()
