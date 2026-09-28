"""One recolourable bean visitor and seven individually switchable costume props."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *


def prop(name, parts, pivot=(0,0,1.30)):
    obj=origin_at(join('prop_'+name,parts),pivot)
    # glTF has no standard visibility flag: the game hides prop_* then picks one.
    obj['default_hidden']=True
    obj['costume_prop']=name
    return obj


def build():
    reset('visitor')
    lathe('body',[(.20,.04),(.30,.13),(.34,.38),(.30,.66),
                  (.22,.87),(.13,.96)],'Body',14)
    ellipsoid('head',(0,-.015,1.115),(.315,.275,.285),'Skin',14,7)
    for side in (-1,1):
        ellipsoid('foot_'+str(side),(side*.17,-.08,.065),(.14,.20,.065),'Body',10,4)
        ellipsoid('arm_nub_'+str(side),(side*.30,-.025,.64),(.105,.12,.16),'Body',8,4)
        ellipsoid('eye_'+str(side),(side*.105,-.275,1.13),(.035,.021,.046),INK,8,4)
    # Upturned, two-segment smile on the front of the head.
    join('smile',[rod('smile_left',(-.065,-.28,1.025),(0,-.288,1.002),.013,INK,6),
                  rod('smile_right',(0,-.288,1.002),(.065,-.28,1.025),.013,INK,6)])

    parts=[lathe('crown_band',[(.285,1.285),(.30,1.30),(.30,1.40),
                              (.255,1.40),(.255,1.285)],GOLD,12,cap=False)]
    for i in range(6):
        a=2*math.pi*i/6
        x,y=.275*math.cos(a),.275*math.sin(a)
        parts.append(lathe('crown_point',[(.085,0),(.012,.16)],GOLD,4,(x,y,1.39)))
    prop('crown',parts)

    parts=[lathe('tiara_band',[(.286,1.29),(.29,1.335),(.258,1.335),
                              (.256,1.29)],GOLD,12,cap=False)]
    for x,z in ((-.17,1.37),(0,1.43),(.17,1.37)):
        parts.append(ellipsoid('tiara_jewel',(x,-.245,z),(.060,.035,.085),ROSE,6,4))
    prop('tiara',parts)

    prop('helmet',[
        lathe('helmet_shell',[(.33,1.25),(.33,1.39),(.25,1.53),(.025,1.60)],SKY,12),
        box('helmet_brow',(0,-.29,1.285),(.57,.09,.075),CREAM),
        box('helmet_crest',(0,.025,1.55),(.08,.36,.16),ROSE,bevel=.025),
    ])
    prop('wizard_hat',[
        lathe('wizard_brim',[(.44,1.31),(.46,1.35),(.34,1.38)],SKY,14),
        lathe('wizard_cone',[(.30,1.37),(.25,1.52),(.16,1.77,.02),
                             (.07,1.94,.12),(.008,1.94,.25)],SKY,12),
        lathe('wizard_ribbon',[(.30,1.39),(.277,1.45)],GOLD,12,cap=False),
        ellipsoid('wizard_badge',(0,-.241,1.58),(.065,.025,.07),GOLD,6,4),
    ])
    prop('chef_hat',[
        lathe('chef_band',[(.285,1.30),(.285,1.47)],CREAM,12),
        lathe('chef_toque',[(.28,1.45),(.37,1.57),(.35,1.72),(.22,1.78)],CREAM,12),
        ellipsoid('chef_puff_left',(-.20,0,1.69),(.19,.26,.17),CREAM,10,5),
        ellipsoid('chef_puff_right',(.20,0,1.69),(.19,.26,.17),CREAM,10,5),
    ])
    prop('guard_cap',[
        lathe('guard_cap_top',[(.29,1.29),(.33,1.36),(.29,1.49),(.06,1.53)],ROSE,12),
        prism('guard_cap_peak',[(-.26,-.18),(-.25,-.40),(0,-.48),
                                (.25,-.40),(.26,-.18)],1.29,1.34,OAK),
        ellipsoid('guard_badge',(0,-.303,1.405),(.052,.018,.065),GOLD,6,4),
    ])
    prop('spear',[
        rod('spear_shaft',(.48,-.08,.08),(.48,-.08,1.52),.027,OAK,8),
        # Closed diamond blade, exaggerated for a phone-sized visitor.
        mesh('spear_tip',[(.48,-.08,1.87),(.37,-.08,1.62),(.48,-.08,1.49),
                          (.59,-.08,1.62),(.48,-.125,1.62),(.48,-.035,1.62)],
             [(0,1,4),(1,2,4),(2,3,4),(3,0,4),
              (1,0,5),(2,1,5),(3,2,5),(0,3,5)],CREAM),
    ],pivot=(.48,-.08,.66))
    export('visitor')


if __name__=='__main__':
    build()
