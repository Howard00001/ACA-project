import numpy as np
import argparse
import xml.etree.cElementTree as ET

def readxml(path):
    '''
    read xml file generated by yolo step
    '''
    tree = ET.ElementTree(file=path)
    hr_root = tree.getroot()
    test_child = []
    for child_of_root in hr_root:
        test_child.append(child_of_root)
    # get locations
    test = [None]*10
    for name_count in range(5):
        tmpx = []
        tmpy = []
        for i in range(len(test_child[2])):
            x = (int(test_child[name_count + 2][i].attrib['x']) + int(test_child[name_count + 2][i].attrib['width']) * 0.5)
            y = (int(test_child[name_count + 2][i].attrib['y']) + int(test_child[name_count + 2][i].attrib['height']) * 0.5)
            tmpx.append(x)
            tmpy.append(y)
        test[name_count*2] = tmpx
        test[name_count*2+1] = tmpy
        
        
    test_loc = np.array(test).T
    test_loc = np.array(test_loc,dtype='int_')
    label = np.array([["Reyex","Reyey","Leyex","Leyey","Rearx","Reary","Learx","Leary","nosex","nosey"]])
    test_loc = np.concatenate([label,test_loc])
    return test_loc

def get_feat(filepath='', feat_sel=1):
    '''
    get features from csv
    feat_sel : 1=>10 distances, 2=>angles, 3=>combination
    '''
    if filepath:
        raw = np.loadtxt(filepath, delimiter=',', skiprows=1, dtype='int_')
    if feat_sel ==1:
        feat = count_dist(raw)
    elif feat_sel==2:
        feat = count_angle(raw)
    elif feat_sel==3:
        feat = combine_feat(raw)
    return feat

def count_dist(raw):
    '''
    count 10 distances for 5 points dlc (raw) in each frame
    '''
    distances = []
    for i in range(5):
        for j in range(i+1, 5):
            p1 = raw[:,2*i:2*i+2]
            p2 = raw[:,2*j:2*j+2]
            distances.append(np.linalg.norm(p2-p1,axis=1))
    return np.array(distances).T

def count_angle(raw, sel=[[1,0,2],[0,1,3]]):
    '''
    count angles for 3 points
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


if __name__=='__main__':
    '''
    python feature_process_front.py --inpath C:\Users\x\Desktop\project\feat\featgen\health_base.xml
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('--inpath', type=str, default='')
    parser.add_argument('--outpath', type=str, default='')
    opt = parser.parse_args()

    if not opt.inpath or (opt.inpath.find('.xml')==-1):
        print('input path error')
    else:
        xmlread = readxml(opt.inpath)
        csvraw = opt.inpath.replace('.xml','.csv')
        np.savetxt(csvraw, xmlread, delimiter=",", fmt="%s")
        feat = get_feat(csvraw,feat_sel=1)

        if not opt.outpath:
            outpath = opt.inpath.replace('.xml','.csv')
            np.savetxt(outpath,feat,delimiter=",")
        else:
            np.savetxt(opt.outpath,feat,delimiter=",")