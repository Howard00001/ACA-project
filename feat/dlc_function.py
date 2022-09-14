import numpy as np
import cv2
import os
import imageio
from sklearn.linear_model import LinearRegression
from functools import reduce


class dlc:
    def __init__(self, dlc_path=None, model_append=None):
        #dlc data
        self.raw = None
        self.raw_wrap = None

        if dlc_path and model_append:
            self.read_dlc(dlc_path, model_append)
            # self.distances, self.vectors, self.directions = self.count_vec()
            # self.angles = self.count_angle(self.distances, self.vectors,0)

    def read_dlc(self, dlc_path, model_append):
        '''
        Read deeplabcut csv, the path would include "/basal_color.avi" or "/treat_color.avi"
        '''
        folder = dlc_path.rsplit("/",1)[0]
        vid_name = dlc_path.rsplit("/",1)[1].replace(".avi","")
        dlc_path = folder + '/'+vid_name+model_append
        getcol = (1,2,4,5,7,8,10,11,13,14)
        raw = np.genfromtxt(dlc_path, delimiter=",")[3:,getcol]
        self.raw = raw.astype(int)
        # wrap 5 different landmark N*10 => N*5*2
        self.raw_wrap = np.zeros([len(raw),5,2],dtype='int')
        for i in range(len(raw)):
            for j in range(10):
                self.raw_wrap[i,int(j/2),j%2] = self.raw[i,j]

class clip_info:
    def __init__(self, clip, raw, directions, vectors):
        # raw info
        self.raw = raw[clip[0]:clip[1],:]
        self.directions = directions[clip[0]:clip[1],...]
        self.vectors = vectors[clip[0]:clip[1],:]
        # self.areas = areas[clip[0]:clip[1]]
        #
        # processed info
        self.count_dir_var() # self.dir_var
        # self.count_area_var() # self.area_var
        # self.count_mean_area() # self.area_mean
        self.count_trajectory_vars() # self.traj_vars
        self.count_trajectory_linear() # self.traj_linear
        #
        # segment types d
        self.segment_type(self.directions) # self.stype
        #

    def no_move(self):
        # set all features to zero
        self.dir_var = -10
        # self.area_var = -10
        # self.area_mean = -10
        self.traj_vars = [-10]*5

    def count_dir_var(self):
        # observe 5 lankmarks' vector direction variance at each frame, than take mean
        self.dir_var = np.mean(np.var(self.directions,axis=1))

    def count_area_var(self):
        self.area_var = np.var(self.areas)

    def count_area_mean(self):
        self.area_mean = np.mean(self.areas)

    def count_trajectory_vars(self):
        self.traj_vars = []
        for i in range(5):
            x = self.raw[:,2*i]
            y = self.raw[:,2*i+1]
            self.traj_vars.append(np.var(x)+np.var(y))
    
    def count_trajectory_linear(self):
        self.traj_linear = []
        for i in range(5):
            x = self.raw[:,2*i].reshape(-1, 1)
            y = self.raw[:,2*i+1]
            reg = LinearRegression().fit(x, y)
            y_p = reg.predict(x)
            self.traj_linear.append(np.mean(abs(y-y_p)))
            # r = max((max(self.raw[:,2*i])-min(self.raw[:,2*i])), len(self.raw[:,2*i])) ##
            # self.traj_linear.append(sum(abs(y-y_p))/r)

    def inf(self):
        '''
        return combination features
        '''
        feat = []
        # feat.append(self.area_var)
        # feat.append(self.area_mean)
        feat.append(self.dir_var)
        feat.extend(self.traj_linear)
        return feat
        # print('length ',self.length)
        # print('dir_range ',self.dir_range)
        # print('tlen ',self.tlen)
        # print('area_r ',self.area_range)
        # print('m_area ',self.m_area)

    def segment_type(self, direction):
        '''
        return segment type by direction of single clip
        observe : direction range, total distance, -1 length
        return charact:
        *static or move
        *straight or rotate
        *big or small motion
        '''
        #thresholds
        static_t=0.7
        rotate_t=3
        mmotion_t=200
        bmotion_t=1000
        #
        dir_move=direction[np.where(direction!=-1)]
        n_len = len(np.where(direction==-1))
        length = len(direction)
        #
        # move or not
        if len(dir_move)==0:
            self.stype =  ['static','','']
            return
        if n_len/length > static_t:
            self.stype = ['static','','']
            return
        else:
            charact = ['move']
        # straight or rotate
        sr = ''
        for i in range(5):
            if self.traj_linear[i] > 1.5:
                sr += 'r'
            else:
                sr += 's'
        if sr.count('s')<sr.count('r') or sr[0:2]=='rr':
            charact.append('rotate')
        else:
            charact.append('straight')
        # charact.append(sr)
        # big or small motion
        if all(x<mmotion_t for x in self.traj_vars):
            charact.append('small')
        elif all(x<bmotion_t for x in self.traj_vars):
            charact.append('medium')
        else:
            charact.append('big')
        
        self.stype=charact

############################################################################################################################
################################# dlc analysis functions ###################################################################
############################################################################################################################
def colorToDepth_crop(cy,cx):
    dy = int(cy*0.3478)
    dx = int(cx*0.3197)
    return dy, dx

def colorToDepth(cy,cx, cbias=[0,0], dbias=[0,0]):
    '''
    mapping color coordinate (cy,cx) to depth coordinate (dy,dx)
    x
    |
    | 
    ----Y

    (parameters reference)
    '''
    cy = cy + cbias[0]
    cx = cx + cbias[1]
    dt1 = -0.02814*cy-0.00704*cx+298.656
    dt2 = -0.0019*cy+0.00971*cx+26.472
    dy = (cy-dt1)/3
    dx = cx/3+dt2
    dy = dy - dbias[0]
    dx = dx - dbias[1]
    return int(dy), int(dx)

def colorToDepth_multi(points, cbias=[0,0], dbias=[0,0]):
    newPoints = []
    for point in points:
        py,px = colorToDepth(point[0],point[1], cbias, dbias)
        # py,px = colorToDepth(point[0],point[1])
        newPoints.append([py+5,px-1])
    return newPoints
        

def dlc_on_img(img, points, rad=2):
    for point in points:
        img = cv2.circle(img, (point[0],point[1]), radius=rad, color=(0, 255, 0), thickness=-1)
    return img

############################################################################################################################
################################# main functions ###########################################################################
############################################################################################################################
def count_vec(data, step=1,threshold=None):
    '''
    count distances and vectors(directions) between frames of deeplabcut data
    threshold: distance set 0 for value under threshold
    dlc_raw shape: N*(2*landmarks) 
    distances shape: (N-1)*landmarks
    vectors shape: (N-1)*landmarks*2
    directions shape: (N-1)*landmarks
    '''
    vectors=[]
    distances = []
    directions = []
    # for each two frames
    for i in range(0,len(data)-step,step):
        distance = []
        vector = []
        direction = []
        # for each two points
        for j in range(int(len(data[0])/2)):
            p1=data[i,2*j:2*j+2]
            p2=data[i+step,2*j:2*j+2]
            #count direction
            vec = p2-p1
            direction.append(np.arctan2(vec[1],vec[0]))
            #
            vector.append(vec)
            dis = np.linalg.norm(vec)
            if threshold and dis<threshold:
                distance.append(0)
            else:
                distance.append(dis)
        vectors.append(vector)
        distances.append(distance)
        directions.append(direction)
    return np.array(distances), np.array(vectors), np.array(directions)

def moving_average(dist, vec, win_size=3, threshold=None, no_move_val='-1'):
    '''
    Generate moving average vector and its direction of certain time from averaging over five landmarks and period of times
    input : dist(disatances), vec(vectors)
    win_size : time for conunting average of one side (total period : 2*win_size+1)
    threshold : tracking movement if lower then threshold direction and vector set to "-1"
    '''
    main_vector = []
    main_direct = []
    # left windows smaller
    for i in range(win_size):
        vec_sum = np.zeros([5,2])
        for k in range(5):
            for j in range(i+win_size):
                vec_sum[k,:] += vec[j,k]
        vec_sum = vec_sum/(i+win_size)
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val=='None':
                main_direct.append([None]*5)
            elif no_move_val == 'prev':
                if len(main_direct)==0:
                    main_direct.append([0]*5)
                main_direct.append(main_direct[-1])
            elif no_move_val == '-1':
                main_direct.append([-1]*5)
        else:
            dirs = []
            for k in range(5):
                dirs.append(abs(np.arctan2(vec_sum[k,1],vec_sum[k,0])))
            main_direct.append(dirs)
    # full windows
    for i in range(win_size,len(vec)-win_size,1):
        vec_sum = np.zeros([5,2])
        for k in range(5):
            for j in range(i-win_size,i+win_size):
                vec_sum[k,:] += vec[j,k]
        vec_sum = vec_sum/(2*win_size+1)
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val=='None':
                main_direct.append([None]*5)
            elif no_move_val == 'prev':
                main_direct.append(main_direct[-1])
            elif no_move_val == '-1':
                main_direct.append([-1]*5)
        else:
            dirs = []
            for k in range(5):
                dirs.append(abs(np.arctan2(vec_sum[k,1],vec_sum[k,0])))
            main_direct.append(dirs)
    # right windows smaller
    for i in range(win_size):
        vec_sum = np.zeros([5,2])
        for k in range(5):
            for j in range(len(vec)-win_size-1+i,len(vec)):
                vec_sum[k,:] += vec[j,k]
        vec_sum = vec_sum/(i+win_size)
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val=='None':
                main_direct.append([None]*5)
            elif no_move_val == 'prev':
                main_direct.append(main_direct[-1])
            elif no_move_val == '-1':
                main_direct.append([-1]*5)
        else:
            dirs = []
            for k in range(5):
                dirs.append(abs(np.arctan2(vec_sum[k,1],vec_sum[k,0])))
            main_direct.append(dirs)
    return np.array(main_vector), np.array(main_direct)

def main_vec(dist, vec, win_size=3, threshold=2, no_move_val='-1'):
    '''
    Generate main vector and its direction of certain time from averaging over five landmarks and period of times
    input : dist(disatances), vec(vectors)
    win_size : time for conunting average of one side (total period : 2*win_size+1)
    threshold : tracking movement if lower then threshold direction and vector set to "-1"
    '''
    main_vector = []
    main_direct = []
    # left windows not enough
    for i in range(win_size):
        vec_sum = np.zeros(2)
        for j in range(i+win_size):
            vec_sum += np.sum(vec[j,:],axis=0)
        vec_sum = vec_sum/(i+win_size)/5
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val == 'None':
                main_direct.append(None)
            elif no_move_val == '-1':
                main_direct.append(-1)
            elif no_move_val == 'prev':
                if len(main_direct)==0:
                    main_direct.append(0)
                main_direct.append(main_direct[-1])
        else:
            main_direct.append(abs(np.arctan2(vec_sum[1],vec_sum[0])))
    # full windows
    for i in range(win_size,len(vec)-win_size,1):
        vec_sum = np.zeros(2)
        for j in range(i-win_size,i+win_size):
            vec_sum += np.sum(vec[j,:],axis=0)
        vec_sum = vec_sum/(2*win_size+1)/5
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val == 'None':
                main_direct.append(None)
            elif no_move_val == '-1':
                main_direct.append(-1)
            elif no_move_val == 'prev':
                main_direct.append(main_direct[-1])
        else:
            main_direct.append(abs(np.arctan2(vec_sum[1],vec_sum[0])))
    # right windows not enough
    for i in range(win_size):
        vec_sum = np.zeros(2)
        for j in range(len(vec)-win_size-1+i,len(vec)):
            vec_sum += np.sum(vec[j,:],axis=0)
        vec_sum = vec_sum/(i+win_size)/5
        main_vector.append(vec_sum)
        if threshold and np.max(dist[i]) < threshold:
            if no_move_val == 'None':
                main_direct.append(None)
            elif no_move_val == '-1':
                main_direct.append(-1)
            elif no_move_val == 'prev':
                main_direct.append(main_direct[-1])
        else:
            main_direct.append(abs(np.arctan2(vec_sum[1],vec_sum[0])))
    return np.array(main_vector), np.array(main_direct)

def vecToDis(vectors):
    '''
    convert vectors to distances
    '''
    return np.linalg.norm(vectors,axis=2)

def count_angle(distances, vectors, threshold=None):
    '''
    count angles change of dlc vectors between each two frames
    threshold: angle not change(keep previous) if distance under threshold
    '''
    data = vectors
    angles=[]
    angle_prev = [0]*len(data[0])
    for i in range(len(data)-1):
        angle = []
        # for each two vectors
        for j in range(int(len(data[0]))):
            v1=data[i,j,:]
            v2=data[i+1,j,:]
            if threshold and distances[i,j]<threshold:
                angle.append(angle_prev[j])
            else:
                vec = v2-v1
                angle.append(np.arctan2(vec[1],vec[0]))
        angles.append(angle)
        angle_prev = angle
    return np.array(angles)

def draw_arrow(raw,img,N):
    '''
    Draw arrow of vector on image
    dlc_point: 2*10 coordinates (two frames)
    N: current frame (to match dlc point)
    '''
    dlc_point = raw.astype(int)
    for i in range(5):
        cv2.arrowedLine(img,
                        tuple(dlc_point[N,i*2:i*2+2]), 
                        tuple(dlc_point[N+1,i*2:i*2+2]),
                        color=(0, 255, 0), 
                        thickness=1, 
                        tipLength=.2)
    return img

def draw_arrow2(raw,vec,img,N):
    '''
    Draw arrow of vector on image
    raw: coordinates
    vec: vectors
    N: current frame (to match dlc point)
    '''
    dlc_point = raw.astype(int)
    vec_int = vec.astype(int)
    for i in range(5):
        x,y = dlc_point[N,i*2:i*2+2]
        x2,y2 =x+vec_int[N,i,0],y+vec_int[N,i,1]
        cv2.arrowedLine(img,
                        tuple([x,y]), 
                        tuple([x2,y2]),
                        color=(0, 255, 0), 
                        thickness=1, 
                        tipLength=.2)
    return img

def put_optical_flow_arrows_on_image(img, opt_img, density=5, threshold=2):
    '''
    put optical flow arrows on image
    '''
    image = img.copy()
    # Turn grayscale to rgb if needed
    if len(image.shape) == 2:
        image = np.stack((image,)*3, axis=2)
    width  = image.shape[1]
    height = image.shape[0]
    for i in range(0,width,density):
        for j in range(0,height,density):
            end = [i,j]
            start = [int(i-opt_img[j,i,1]),int(j-opt_img[j,i,0])]
            if np.linalg.norm(np.array(end)-np.array(start)) > threshold:
                cv2.arrowedLine(image,start,end,color=(0,255,0),thickness=1,tipLength=.2)

    return image

def count_moment(data):
    '''
    count N moment of landmark movement by N-1 moment (moving distance)
    '''
    dis = data
    dis2 = []
    for i in range(len(dis)-1):
        dis2.append(dis[i+1,...]-dis[i,...])
    return np.array(dis2)

def video_segment(directions, threshold=10, discard=True):
    '''
    Split the video by -1 in the direction and threshold
    directions : the 1-dim singnal
    threshold : very short clip filter
    '''
    md = directions
    types = []
    clips = []
    clip = np.zeros(2,'int') # clip : [start, end]
    length = 1
    for i in range(1,len(md)):
        if ((md[i-1]==-1 and not md[i]==-1) or (not md[i-1]==-1 and md[i]==-1)):
            if length < threshold: #ignore very short clip
                length=0
                if discard:
                    clip[0] = i
            else:
                length=0
                clip[1] = i-1
                clips.append(clip)
                clip = np.zeros(2,'int')
                clip[0] = i
        length += 1
    #last clip
    if clip[1]!=len(md) and length>threshold:
        clip[1]=len(md)
        clips.append(clip)
    return np.array(clips)

def generate_type(clips, directions, distances, vectors):
    '''
    generate type for each clip
    '''
    types = []
    for clip in clips:
        direct = directions[clip[0]:clip[1],...]
        # vec = vectors[clip[0]:clip[1],...]
        # dist = distances[clip[0]:clip[1],...]
        types.append(segment_type(direct))
    return types

def segment_type(direction):
    '''
    return segment type by direction of single clip
    observe : direction range, total distance, -1 length
    return charact:
    *static or move
    (*straight or rotate)
    (*big or small motion)
    '''
    static_t=0.7
    dir_move=direction[np.where(direction!=-1)]
    n_len = len(np.where(direction==-1))
    length = len(direction)
    # move or not
    if len(dir_move)==0:
        return 'static'
        # return ['static','','']
    if n_len/length > static_t:
        return 'static'
        # return ['static','','']
    else:
        return 'move'
        # charact = ['move']
    # straight or rotate
    
    # big or small motion
    
    
    return charact

def clip_direction_change(clips,directions):
    '''
    reclip the clips where directions are difference (second moment=0) 
    '''
    moment2 = count_moment(directions)

def clip_data(data,clips):
    '''
    return data splitted by clips
    '''
    out = []
    # clip : [start, end]
    for clip in clips:
        if clip[1] > len(data):
            break
        rs = data[clip[0]:clip[1]+1,...]
        out.append(rs)
    return out

def clips_len(clips):
    '''
    return length of all clips
    '''
    return clips[:,1]-clips[:,0]

def count_optflow(vid_path, mask=True, stop=None, white_back=False):
    '''
    count optical flow Fx,Fy for all points in video
    mask: remove noise flow by mice roi mask (frame==0)
    '''
    cap = cv2.VideoCapture(vid_path)
    flows = []
    ret, frame = cap.read()
    prvs = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    prvs = cv2.equalizeHist(prvs)
    if white_back:
        prvs[np.where(prvs==0)]=255
    i=0
    while(1):
        ret, frame = cap.read()
        if not ret:
            break
        if stop and i>=stop:
            break
        next = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        next = cv2.equalizeHist(next)
        if white_back:
            next[np.where(next==0)]=255
        flow = cv2.calcOpticalFlowFarneback(prvs, next, None, 0.5, 3, 5, 3, 5, 5, 0)
        # dtvl1=cv2.optflow.DualTVL1OpticalFlow_create()
        # flow = dtvl1.calc(prvs,next,None)
        if mask:
            flow[np.where(next==0)]=0
        flows.append(flow)
        i+=1
    return np.array(flows)

def regional_flow(flows, raw, win_size=20):
    '''
    Generate 5 flows by DLC points and their widows and taking avg(median)
    return flows shaped like vec
    '''
    rflows = []
    for i in range(0,len(flows)):
        rflow=[]
        for j in range(5):
            x,y = raw[i+1,2*j:2*j+2]
            w = int(win_size/2) 
            x_region = flows[i,x-w:x+w+1,y-w:y+w+1,0]
            y_region = flows[i,x-w:x+w+1,y-w:y+w+1,1]
            rflow.append([np.mean(x_region),np.mean(y_region)])
        rflows.append(rflow)
    return np.array(rflows)

def flow_to_signal(f, pool_type='avg'):
    '''
    convert motion flow map to single dimension signal
    '''
    signal = []
    for i in range(len(f)):
        fi = f[i]
        f_mask = fi[np.where(fi!=0)]
        if pool_type=='avg':
            signal.append(np.mean(f_mask))
        elif pool_type=='max':
            signal.append(np.max(f_mask))
    return signal    

def mice_area(vid_path):
    '''
    detect mice area in each frame to observe stretch and clinge
    '''
    cap = cv2.VideoCapture(vid_path)
    areas = []
    while(cap.isOpened()):
        ret,frame = cap.read()
        if not ret:
            break
        areas.append(len(np.where(frame==0)[0]))
    return np.array(areas)

def clip_feat(clips, raw, directions, vectors):
    '''
    generate simple features and segment types for each clip in "clips"
    '''
    feats = []
    types = []
    for i in range(len(clips)):
        tmpinf = clip_info(clips[i], raw, directions, vectors)
        feats.append(tmpinf.inf())
        types.append(tmpinf.stype)
    return np.array(feats), types

def clip_type_encode(types):
    '''
    convert type list to cluster number
    '''
    type_code = []
    for tp in types:
        if tp[0] == 'static':
            type_code.append(0)
            continue
        if tp[1]=='straight':
            if tp[2] == 'small':
                type_code.append(1)
                continue
            if tp[2] == 'medium':
                type_code.append(2)
                continue
            if tp[2] == 'big':
                type_code.append(3)
                continue
        if tp[1]=='rotate':
            if tp[2] == 'small':
                type_code.append(4)
                continue
            if tp[2] == 'medium':
                type_code.append(5)
                continue
            if tp[2] == 'big':
                type_code.append(6)
                continue
    return type_code

##############################################################################
############################### video out funcion ############################
##############################################################################
def clip_vid(vid_path, clips, out_path):
    cap = cv2.VideoCapture(vid_path)
    target_fps   = round(cap.get(cv2.CAP_PROP_FPS))
    frame_width  = round(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = round(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fourcc = int(cap.get(cv2.CAP_PROP_FOURCC))

    if not os.path.isdir(out_path):
        os.makedirs(out_path)

    vid_i=0
    clip = clips[vid_i]
    out = cv2.VideoWriter(out_path+"/0.avi",fourcc, 10, (frame_width, frame_height))
    ret, frame = cap.read()
    out.write(frame)
    i =0
    while(cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            out.release()
            break
        # if frame in clip
        if i>=clip[0]:
            out.write(frame)
        # if split point reached
        if i == clip[1]:
            out.release()
            vid_i += 1
            out = cv2.VideoWriter(out_path+"/"+str(vid_i)+".avi",fourcc, 10, (frame_width, frame_height))
        i +=1
    cap.release()

def clip_gif(vid_path, clips, out_path):
    '''
    save video clips gif to out_path
    '''
    cap = cv2.VideoCapture(vid_path)

    if not os.path.isdir(out_path):
        os.makedirs(out_path)

    vid_i=0
    imgs = []
    clip = clips[vid_i]
    i=0
    while(cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            break
        # frame in clip
        if i>=clip[0]:
            imgs.append(frame)
        # split point reached
        if i == clip[1]:
            imageio.mimsave(out_path+"/"+str(vid_i)+".gif",imgs)
            imgs = []
            vid_i += 1
            if vid_i < len(clips):
                clip = clips[vid_i]
        i+=1
    cap.release()

def arrowed_gif(vid_path, flows, output_name, end=None):
    '''
    output video with optical flow arrows
    '''
    imgs = []
    cap = cv2.VideoCapture(vid_path)
    i=0
        
    while(cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            break
        if end and i>end:
            break
        frame = put_optical_flow_arrows_on_image(frame, flows[i])
        imgs.append(frame)
        i+=1
    imageio.mimsave(output_name,imgs)

def classes_gif(vid_path, clips, y_pred, out_path):
    '''
    output videos clips to different folder by cluster prediction
    '''
    cap = cv2.VideoCapture(vid_path)
    if not os.path.isdir(out_path):
        os.makedirs(out_path)

    vid_i=0
    imgs = []
    clip = clips[vid_i]
    i=0
    while(cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            break
        if i>=clip[0]:
            imgs.append(frame)
        # if split point reached
        if i == clip[1]:
            out_path_c = out_path+'/'+str(y_pred[vid_i])+'/'
            if not os.path.isdir(out_path_c):
                os.makedirs(out_path_c)
            imageio.mimsave(out_path_c+str(vid_i)+".gif",imgs)
            imgs = []
            vid_i += 1
            if vid_i < len(clips):
                clip = clips[vid_i]
        i+=1
    cap.release()


################################################################################
################################## motion map ##################################
################################################################################
def grad_x(f):
    '''
    count gradient map of x direction of each motion map in f
    f: bunch of motion maps
    '''
    # res = np.zeros_like(f)
    # for i in range(len(f[0])-1):
    #     res[:,i,:] = f[:,i+1,:]-f[:,i,:]
    # return  res
    return np.gradient(f, axis=1)

def grad_y(f):
    '''
    count gradient map of y direction of each motion map in f
    f: bunch of motion maps
    '''
    # res = np.zeros_like(f)
    # for i in range(len(f[1])-1):
    #     res[:,:,i] = f[:,:,i+1]-f[:,:,i]
    # return  res
    return np.gradient(f, axis=2)

def divergence(f1,f2):
    # res = []
    # for i in range(len(f1)):
    #     res.append([np.trace(f1[i], np.trace(f2[i]))])
    # return np.array(res)
    return reduce(np.add,[f1,f2])

def curl(dxfy,dyfx):
    # res = []
    # for i in range(len(dxfy)):
    #     res.append((dxfy[i]-dyfx[i]).T)
    # return np.array(res)
    return (dxfy-dyfx)

def count_motion_map(flow, gaussian_filter=True):
    fx = flow[:,:,:,0]
    fy = flow[:,:,:,1]
    dxfx = grad_x(fx)
    dyfy = grad_y(fy)
    divF = divergence(dxfx,dyfy)
    curlF = curl(grad_x(fy),grad_y(fx))
    if gaussian_filter:
        fx = cv2.GaussianBlur(fx, (5,5), 0)
        fy = cv2.GaussianBlur(fy, (5,5), 0)
        dxfx = cv2.GaussianBlur(dxfx, (5,5), 0)
        dyfy = cv2.GaussianBlur(dyfy, (5,5), 0)
        divF = cv2.GaussianBlur(divF, (5,5), 0)
        curlF = cv2.GaussianBlur(curlF, (5,5), 0)
    return [fx,fy,dxfx,dyfy,divF,curlF]

def map_maxpool(mmaps):
    '''
    generate maxpool signal from 6 motion map
    '''
    signals = []
    for maps in mmaps:
        signal = []
        for map_frame in maps:
            signal.append(np.max(map_frame))
        signals.append(np.array(signal))
    return signals

################################################################################
################################ wave analyze ##################################
################################################################################
from WT import transform,wavelets

def cwt_signal(signal, clips, len_crop=True, sample=True):
    '''
    count the continious wavelet transform of all signal
    min_len : shortest signal (longest wavelet)
    sample_len : taking samples through frames to keep same length for all result
    '''
    powers = []
    for clip in clips:
        x = signal[clip[0]:clip[1]]
        t = np.arange(len(x))
        dt = 1              # sampling frequency
        dj = 0.2             # scale distribution parameter
        wavelet = wavelets.Morlet()
        wa = transform.WaveletTransformTorch(dt, dj, wavelet, cuda=True)

        #cwt = wa.cwt(x) # Eular format
        power = wa.power(x)
        if len_crop:
            min_len = min(clips[:,1]-clips[:,0])
            power = power[0:min_len,:]
            if sample:
                sample_len=min_len+1
                ind = np.arange(len(x))
                step = len(x)/sample_len
                sel = []
                for i in range(sample_len):
                    s = int(i*step)
                    sel.append(ind[s])
                power = power[:,sel]
        powers.append(power)
    return powers

def cwt_all(maxsignals, clips, len_crop=True, sample=True):
    '''
    doing continious wavelet transform for six motion map max signals
    '''
    cwtmaps=[]
    for signals in maxsignals:
        cwts = cwt_signal(signals, clips, len_crop, sample)
        cwtmaps.append(cwts)
    return np.array(cwtmaps)

def cwt_full(signals, clips, len_crop, sample):
    '''
    doing continious wavelet transform for six motion map max signals full len
    '''
    cwts = cwt_signal(signals, clips, len_crop, sample)
    return np.array(cwts)
