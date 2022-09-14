import numpy as np
import cv2
import argparse

class dlc:
    def __init__(self, dlc_path=None):
        #dlc data
        self.raw = None
        self.raw_wrap = None

        if dlc_path:
            self.read_dlc(dlc_path)

    def read_dlc(self,dlc_path):
        getcol = (1,2,4,5,7,8,10,11,13,14,16,17,19,20)
        raw = np.genfromtxt(dlc_path, delimiter=",")[3:,getcol]
        self.raw = raw.astype(int)
        # wrap 5 different landmark N*10 => N*5*2
        self.raw_wrap = np.zeros([len(raw),7,2],dtype='int')
        for i in range(len(raw)):
            for j in range(14):
                self.raw_wrap[i,int(j/2),j%2] = self.raw[i,j]

def mice_area(vid_path):
    '''
    detect mice area in each frame
    '''
    cap = cv2.VideoCapture(vid_path)
    areas = []
    while(cap.isOpened()):
        ret,frame = cap.read()
        if not ret:
            break
        areas.append(len(np.where(frame==0)[0]))
    return np.array(areas)


def count_dist(raw):
    '''
    count 10 distances for 5 points dlc (raw) in each frame
    '''
    distances = []
    sel = [[0,1],[0,2],[1,3],[2,3],[3,4],[3,5],[4,6],[5,6]]
    for [i,j] in sel:
        p1 = raw[:,2*i:2*i+2]
        p2 = raw[:,2*j:2*j+2]
        distances.append(np.linalg.norm(p2-p1,axis=1))
    return np.array(distances).T

def count_angle(raw, sel=[[0,3,6]]):
    '''
    count angles for 5 points dlc (raw) in each frame
    sel: angle of selected points (example:[[0,1,2],[1,2,3]] => angle of points)
    '''
    angle = []
    for p1,p2,p3 in sel:
        v1 = raw[:,2*p1:2*p1+2]-raw[:,2*p2:2*p2+2]
        v2 = raw[:,2*p3:2*p3+2]-raw[:,2*p2:2*p2+2]
        angle.append(abs(np.arctan2(v1[:,0],v1[:,1])-np.arctan2(v2[:,0],v2[:,1])))
    return np.array(angle).T

def combine_feat(raw):
    '''
    return concatenation of distance and angle
    '''
    d = count_dist(raw)
    a = count_angle(raw)
    return np.hstack([d,a])

def generate_tmpfeat(feat):
    tmp_feat = []
    for i in range(int(len(feat)/10)):
        tmp_feat.append(feat[i*10:i*10+10])
    return np.array(tmp_feat)

def generate_mskfeat(feat):
    msk_feat = []
    for i in range(int(len(feat)/10)):
        msk = feat[i*10:i*10+10]
        mx = np.max(msk, axis=0)
        # mn = np.min(msk, axis=0)
        std = np.std(msk, axis=0)
        avg = np.mean(msk, axis=0)
        newfeat = np.concatenate([mx,std,avg])
        msk_feat.append(newfeat)
    return np.array(msk_feat)

def default_out(path):
    path = path.replace('\\','/')
    sp = path.rsplit('/',1)
    if sp[-1].find('basal')!=-1:
        bt = 'basal'
    else:
        bt = 'treat'
    return sp[0]+'/'+bt+'_feat.csv'


if __name__=='__main__':
    '''
    input raw (deeplabcut) csv file and generate feature csv to same folder
    output default name : {input exp name}.csv
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('--inpath', type=str, default='')
    parser.add_argument('--outpath', type=str, default='')
    opt = parser.parse_args()

    if not opt.inpath:
        print('input path error')
    else:
        path = opt.inpath
        dlc1 = dlc(path)
        feat = combine_feat(dlc1.raw)

        if not opt.outpath:
            outpath = default_out(path)
            np.savetxt(outpath,feat,delimiter=",")
        else:
            np.savetxt(opt.outpath,feat,delimiter=",")
