function show_annotation_KITTI_multi_car

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';

seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};

for i = 1:numel(seq_names)
   seq_name = seq_names{i};
   disp(seq_name);
   % load ground truth
   gt_path = fullfile(root_path, seq_name, [seq_name '.mat']);
   object = load(gt_path);
   data = object.data;
   
   % list images
   img_path = fullfile(root_path, seq_name, 'img');
   img_file = fullfile(img_path, '*.png');
   filenames = dir(img_file);
   N = numel(filenames);
   
   for j = 1:N
       filename = fullfile(img_path, filenames(j).name);
       I = imread(filename);
       figure(1);
       imshow(I);
       hold on;
       % draw bounding box
       bbox = data(j,1:4);
       bbox_draw = [bbox(1), bbox(2), bbox(3)-bbox(1), bbox(4)-bbox(2)];
       rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
       % show rotation angle
       alpha = data(j,5)*180/pi;
       if alpha < 0
           alpha = alpha + 360;
       end
       alpha = alpha - 90;
       if alpha < 0
           alpha = alpha + 360;
       end
       tit = sprintf('alpha = %.2f\n', alpha);
       title(tit);
       hold off;
       pause;
   end
end