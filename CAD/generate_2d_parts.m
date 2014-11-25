% render parts into an image
% d: viewpoint distance
% M: viewport size
function part2d = generate_2d_parts(cls, azimuth, elevation, distance)

switch cls
    case 'car'
        occ_per = [0.2 0.3 0.3 0.7 0.7 0.2];
        M = 3000;
        tilt_threshold = [75 78 78 78 78 75];
        path = '/home/yuxiang/Projects/Multiview_Tracking/CAD/car.mat';
end

object = load(path);
cad = object.(cls);
pnames = cad.pnames;

% viewport size
R = M * [1 0 0.5; 0 -1 0.5; 0 0 1];
R(3,3) = 1;

part2d.azimuth = azimuth;
part2d.elevation = elevation;
part2d.distance = distance;
part2d.viewport = M;
part2d.root = 0;
part2d.graph = zeros(numel(pnames));
for i = 1:numel(pnames)
    part2d.(pnames{i}) = [];
end

% render CAD model
cad.roots = zeros(1, numel(occ_per));
[parts, occluded, parts_unoccluded] = render(cls, cad, azimuth, elevation, distance);

% part number
N = numel(parts);
part2d.centers = zeros(N, 2);
part2d.homographies = cell(N, 1);

for i = 1:N
    if cad.roots(i) == 0
        % occluded percentage
        if occluded(i) > occ_per(i)
            continue;
        end
    end

    % map to viewport
    p = R*[parts_unoccluded(i).x parts_unoccluded(i).y ones(numel(parts_unoccluded(i).x), 1)]';
    p = p(1:2,:)';
    c = R*[parts_unoccluded(i).center, 1]';
    c = c(1:2)';

    % translate the part center to the orignal
    part2d.(pnames{i}) = p - repmat(c, size(p,1), 1);
    part2d.centers(i,:) = c';

    % compute the homography for transfering current view of the part
    % to frontal view using four point correspondences
    % coefficient matrix
    A = zeros(8,9);
    % construct the coefficient matrix
    X = part2d.(pnames{i});
    xprim = cad.parts2d_front(i).vertices;
    for j = 1:4
        x = [X(j,:), 1];
        A(2*j-1,:) = [zeros(1,3), -x, xprim(j,2)*x];
        A(2*j, :) = [x, zeros(1,3), -xprim(j,1)*x];
    end
    [~, ~, V] = svd(A);
    % homography
    h = V(:,end);
    H = reshape(h, 3, 3)';
    % normalization
    H = H ./ H(3,3);      
    part2d.homographies{i} = H;
end

part2d = remove_large_tilt(cad, part2d, tilt_threshold);
part2d.pnames = cad.pnames(1:N);