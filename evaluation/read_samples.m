% read one sample from file
function examples = read_samples(filename, cad, N)

% open prediction file
fid = fopen(filename, 'r');

examples = cell(N,1);
for i = 1:N
    num = fscanf(fid, '%d', 1);
    example = [];
    for j = 1:num
        example(j).object_label = fscanf(fid, '%d', 1);
        example(j).cad_label = fscanf(fid, '%d', 1);
        example(j).view_label = fscanf(fid, '%d', 1) + 1;
        example(j).energy = fscanf(fid, '%f', 1);
        part_num = numel(cad.pnames);
        example(j).part_label = fscanf(fid, '%f', part_num*2);
        example(j).part_label = reshape(example(j).part_label, part_num, 2);
        example(j).bbox = fscanf(fid, '%f', 4)';
        example(j).bbox = refine_bbox(example(j), cad);
    end
    examples{i} = example;
end

function bbox = refine_bbox(example, cad)

part_label = example.part_label;
pnames = cad.pnames;
part_num = numel(pnames);
view_label = example.view_label;
part2d = cad.parts2d(view_label);

bbox = [inf inf -inf -inf];

for a = 1:part_num-8
    if isempty(part2d.homographies{a}) == 0 && part_label(a,1) ~= 0 && part_label(a,2) ~= 0
        part = part2d.(pnames{a}) + repmat(part_label(a,:), 5, 1);
        bbox(1) = min(bbox(1), min(part(:,1)));
        bbox(2) = min(bbox(2), min(part(:,2)));
        bbox(3) = max(bbox(3), max(part(:,1)));
        bbox(4) = max(bbox(4), max(part(:,2)));
    end
end