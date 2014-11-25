function create_annotations_TLD

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD';

seq_names = {'06_car'};

for s = 1:numel(seq_names)
    seq_name = seq_names{s};
    disp(seq_name);
    
    % load annotation
    filename = fullfile(root_path, seq_name, 'gt.txt');
    fid = fopen(filename, 'r');
    C = textscan(fid, '%f %f %f %f', 'delimiter', ',');
    fclose(fid);
    
    % read the file name for each image
    filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
    N = numel(filenames);
    % write the annotation file
    for i = 1:N
        filename = fullfile(root_path, seq_name, 'gt', [filenames{i}(1:end-3) 'mat']);
        record.filename = filenames{i};
        bbox = [C{1}(i) C{2}(i) C{3}(i)-C{1}(i) C{4}(i)-C{2}(i)];
        record.objects(1).bbox = bbox;
        record.objects(1).class = 'car';
%         alpha = data(i,5)*180/pi;
%         if alpha < 0
%             alpha = alpha + 360;
%         end
%         alpha = alpha - 90;
%         if alpha < 0
%             alpha = alpha + 360;
%         end        
%         record.objects(1).viewpoint.azimuth_KITTI = alpha;
        save(filename, 'record');
    end
end