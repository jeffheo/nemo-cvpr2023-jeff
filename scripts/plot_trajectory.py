import torch
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import pickle
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--action', type=str, default='walking.0')
parser.add_argument('--description', type=str, default='S1')

args = parser.parse_args()

def plot_trajectories(body_pos, camera_pos):
    fig = plt.figure(figsize=(10, 10))
    ax = fig.add_subplot(111, projection='3d')

    # Create an array to represent the size of each point
    time = np.arange(body_pos.shape[0])
    point_sizes = time   # adjust the scaling factor as needed
    print("shape of body_pos: ", body_pos.shape)
    print("shape of camera_pos: ", camera_pos.shape)

    # Plot every 10 frames
    body_pos = body_pos[::80]
    camera_pos = camera_pos[::80]
    point_sizes = point_sizes[::80]

    
    ax.scatter(body_pos[:, 0], body_pos[:, 1], body_pos[:, 2], 
               c='r', 
               s=point_sizes, edgecolors='r', depthshade=True, alpha=0.7)

    ax.scatter(camera_pos[:, 0], camera_pos[:, 1], camera_pos[:, 2], 
               c='b', 
               s=point_sizes, edgecolors='b', depthshade=True, alpha=0.7)


    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.legend(['Body Movement', 'Camera'])
    plt.title('3D trajectory of body and camera motion')
    fig.savefig(f'trans_map/new_cam/{args.action}_{args.description}_trajectory.png', dpi=500)    
    plt.show()



with open(f'trans_map/new_cam/{args.action}_plot_dict.pkl', 'rb') as f:
    data = pickle.load(f)
human_position = data['smpl_trans'].cpu().detach().numpy()
camera_position = data['droidslam_cam'].cpu().detach().numpy()
plot_trajectories(human_position, camera_position)
