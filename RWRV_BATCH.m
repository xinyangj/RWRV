%%
%==========================================================================
% Notice
%==========================================================================
%
% This is the source code of RWRV (Random Walk with Restart on Video)
% represented in TIP.
%
% It is free for academic and non-commercial use.
% If you use the software in your research,
% please cite the following reference paper.
%
% Hansang Kim, Youngbae Kim, Jae-Young Sim, and Chang-Su Kim,
% "Spatiotemporal saliency detection for video sequences based on
% random walk with restart," IEEE Trans. Image Process.,
% vol. 24, no. 8, pp. 2552-2564, 2015.
%
% You can also download test sequences from the following site.
% MCL database, http://mcl.korea.ac.kr/database/saliency/
%
% Author : hansangkim@mcl.korea.ac.kr
%          youngbaekim@mcl.korea.ac.kr
% Affiliation : Korea University
%
%%
%==========================================================================
% File Information
%==========================================================================
% RWRV_EXE : Execution file of RWRV
% PatchRepresentation.m : generate patch for making image as graph
%
% RWRV_S : get spatial saliency map
% SpatialFeatureExtraction : get color/contrast features
% ColorCompactness : get color compactness feature
% SpatialSaliencyDetection : compute RW
%
% RWRV_ST : get spatiotemporal saliency map
% TemporalFeatureExtraction : get temporal features
% SpatiotemporalSaliencyDetection : compute RWR
%
% PreBlackBarDetection : pre-process for detecting black-bar
% PreGlobalMotionDetection : pre-process for getting global motion
% PreGetAlignedPicture : pre-process for getting aligned picture
%
%%
%==========================================================================
% Revision History
%==========================================================================
%
% v0.1 : First authored 1/31/2014
% v0.5 : Revised 8/31/2014
% v1.0 : Revised 5/31/2015
%
%==========================================================================

%% Main for spatiotemporal saliency detection based on RWR

clear
close
clc
format compact
matlabpool 2

sequence_path = 'D:\Documents\Projects\Libraries\RWRV\MCL_dataset\Sequence\';
saliency_path = 'D:\Documents\Projects\Libraries\RWRV\MCL_dataset\Saliency\';
ext = 'png';

video_list = dir(sequence_path);
video_list = video_list([video_list.isdir]);
video_list = video_list(3:end);
total_cnt = size(video_list, 1);



parfor j=1:total_cnt
    start_frm_num = 1;
    frame_list = dir([sequence_path, video_list(j).name, '/*.' ,ext]);
    stop_frm_num = size(frame_list, 1);
           
    video_name = char(video_list(j).name);
       
    mkdir(strcat(saliency_path,'\',video_name));
      
    for i=start_frm_num:stop_frm_num
            
        i
        ifile_cur = strcat(sequence_path,'\',video_name,'\',frame_list(i).name);
            
        if i>start_frm_num
            ifile_ref_p = strcat(sequence_path,'\',video_name,'\',frame_list(i).name);
            if  i~=stop_frm_num
                ifile_ref_n = strcat(sequence_path,'\',video_name,'\',frame_list(i).name);
            end
        end
            
        uiImg_c = imread(ifile_cur);
        [iSizeH, iSizeW] = size(uiImg_c);
        iSizeW = iSizeW/3;
            
        % For checking name
        [in_path, in_name, in_ext] = fileparts(ifile_cur);
        if i>start_frm_num
            [in_path, in_name_rp, in_ext_r] = fileparts(ifile_ref_p);
            if  i~=stop_frm_num
                [in_path, in_name_rn, in_ext_r] = fileparts(ifile_ref_n);
            end
        end
            
        % Initialization
        intra_flag = 0;
        is_last = 0;
        
        % First frame only , You can also set after detecting 'Scene Change'
        if i==start_frm_num
            intra_flag = 1;
        end
        
        out_path = strcat(saliency_path,'\',video_name,'\');
        if intra_flag==1
            
            % Spatial Saliency Detection
            uiOut2 = RWRV_S(in_path,in_name, in_ext);
            
            sfile2 = strcat(out_path,in_name, '_sal',in_ext);
            uiOut = imresize(uiOut2, [iSizeH iSizeW], 'bicubic');
            imwrite(uiOut, sfile2);
        else
                
            if i==stop_frm_num
                is_last=1;
            end
               
            % Spatiotemporal Saliency Detection
            [uiOut1, uiSal] = RWRV_ST(in_path,out_path,video_name,i,in_ext,uiOut2,is_last);
                
            % Back up saliency map for the next frame
            uiOut2 = uiOut1;
                
            sfile1 = strcat(out_path,in_name, '_sal',in_ext);
            uiOut_sal = imresize(uiOut1, [iSizeH iSizeW], 'bicubic');
            imwrite(uiOut_sal, sfile1);
                
        end
    end
end
matlabpool close
