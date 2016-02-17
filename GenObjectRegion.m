video_path = 'D:\Documents\Projects\Libraries\RWRV\MCL_dataset\saliency/';
ext = 'png';
boxes = [[30, 30], [50, 70]];
step = 10;
C = 5;
thres = 0.7;

video_list = dir(video_path);
video_list = video_list([video_list.isdir]);
video_list = video_list(3:end);


for i = 1:size(video_list, 1)
    frame_list = dir([video_path, video_list(i).name, '/*.' ,ext]);
    
    for j = 1:size(frame_list, 1)
        result = [];
        for k = 1:size(boxes, 1)
            saliency_map = imread([video_path, video_list(i).name, '/', frame_list(j).name]);
            saliency_map = im2single(saliency_map);
            sum_i = sum(sum(saliency_map));
            h = boxes(k, 1);
            w = boxes(k, 2);
            sum_w = filter2(ones(h, w), saliency_map, 'valid');
            score = sum_w / sum_i + sum_w / (C + h * w);
            [y, x] = find(score > thres);
            region = [y, x, ([y, x] + repmat([h, w], size(y, 1), 1) -1), score(sub2ind(size(score),y, x))];
            result = [result; region];
        end
        pick = nms(result, 0.5);
        region = result(pick, :);
    end
end