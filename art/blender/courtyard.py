"""Open workshop backdrop, left kiln and right pottery bench, under 3000 tris."""
from pathlib import Path
import random
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *


def build():
    reset('courtyard')
    rng=random.Random(928)
    box('floor_grout',(0,0,.025),(12,12,.05),OAK)
    pavers=[]
    # Forty-two broad, clipped cobbles: legible on phones without dense geometry.
    for row in range(7):
        for col in range(6):
            x=-5+col*2; y=-6+(row+.5)*12/7
            w=.965; h=12/14-.035; cut=rng.uniform(.12,.24)
            outline=[(x-w+cut,y-h),(x+w-cut,y-h),(x+w,y-h+cut),
                     (x+w,y+h-cut),(x+w-cut,y+h),(x-w+cut,y+h),
                     (x-w,y+h-cut),(x-w,y-h+cut)]
            colour=CLAY if (row*6+col)%13==0 else CREAM
            pavers.append(prism('cobble',outline,.05,.08+rng.uniform(0,.016),colour))
    join('cobbled_floor',pavers)

    # Clear view through the middle: a 6.6-wide gap for castle_base and towers.
    wall('back_wall_left',(-6,5.6,0),(-3.3,5.6,0),.70)
    wall('back_wall_right',(3.3,5.6,0),(6,5.6,0),.70)

    x,y=-4.40,1.25
    box('kiln_hearth',(x,y,.10),(1.85,1.80,.20),CREAM)
    # Deep arched shell, with the doorway genuinely open at the front.
    arch_frame('kiln_vault',x,y,.12,.58,.85,.32,1.30,CREAM,10)
    arch_shape('kiln_back',x,y+.64,.12,.59,.85,.10,CLAY)
    arch_shape('kiln_dark_interior',x,y+.58,.15,.53,.84,.025,INK)
    arch_shape('kiln_warm_interior',x,y+.56,.15,.35,.65,.025,GOLD,8)
    arch_frame('kiln_front_arch',x,y-.69,.12,.58,.85,.20,.18,CREAM,9)
    box('kiln_chimney',(x+.28,y+.32,1.87),(.42,.42,.58),CLAY)
    box('kiln_chimney_cap',(x+.28,y+.32,2.18),(.56,.56,.10),CREAM)
    box('kiln_chimney_soot',(x+.28,y+.32,2.232),(.29,.29,.008),INK)
    for i in range(3):
        rod(f'kiln_log_{i+1}',(x-.33+i*.32,y-.48,.22),
            (x-.30+i*.32,y+.23,.22),.09,OAK,6)
    # Use this transform to place kiln_door.glb. Its pivot stays in that asset.
    empty('kiln_door_mount',(x,y-.80,0))

    x,y=4.35,.75
    box('bench_top',(x,y,1.03),(2.45,1.1,.18),OAK,bevel=.035)
    for dx in (-.97,.97):
        for dy in (-.36,.36):
            box(f'bench_leg_{dx}_{dy}',(x+dx,y+dy,.53),(.17,.17,.98),OAK)
    box('bench_lower_shelf',(x,y,.28),(2.2,.89,.10),OAK)
    for i,colour in enumerate((SAGE,ROSE)):
        bowl(f'glaze_bowl_{i+1}',(x-.77+i*.69,y-.07,1.12),.29,colour)
    lathe('tool_pot',[(.19,0),(.23,.05),(.24,.42),(.26,.47),
                      (.20,.47),(.18,.11),(.03,.09)],CREAM,12,(x+.70,y,1.12),True)
    for i in range(3):
        rod(f'wooden_tool_{i+1}',(x+.57+i*.12,y,1.28),
            (x+.43+i*.23,y+.05,1.91-abs(i-1)*.08),.035,OAK,6)
    export('courtyard')


if __name__=='__main__':
    build()
