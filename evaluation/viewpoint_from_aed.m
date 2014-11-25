function [ viewpoint ] = viewpoint_from_aed( param, aed )

n_parts       = numel(param.cad.pnames);
n_parts_child = numel(param.cad.parts);

[~, ~, parts_unoccluded] = render(param.category, param.cad, aed(1), aed(2), aed(3));

n_a = numel(param.cad.azimuth);
n_e = numel(param.cad.elevation);
n_d = numel(param.cad.distance);
[~, idx_a] = min(mod(abs(aed(1)*ones( 1, n_a+1 ) - [param.cad.azimuth   360]),360));
[~, idx_e] = min(mod(abs(aed(2)*ones( 1, n_e   ) - param.cad.elevation      ),360));
[~, idx_d] = min(mod(abs(aed(3)*ones( 1, n_d   ) - param.cad.distance       ),360));
if( idx_a == n_a+1 )
    idx_a = 1;
end

viewpoint.aed  = [aed(1), aed(2), aed(3)];
viewpoint.parts = cell(n_parts,1);
viewpoint.n_unoccluded = 0;
viewpoint.idx_unoccluded = [];

R = param.cad.parts2d_front(1).viewport * [1 0 0.5; 0 -1 0.5; 0 0 1];
R(3,3) = 1;

for i=1:n_parts
    
    viewpoint.parts{i}.is_occluded = ...
        isempty(param.cad.parts2d(n_d*n_e*(idx_a-1) + n_d*(idx_e-1) + idx_d).(param.cad.pnames{i}));
    if( ~viewpoint.parts{i}.is_occluded )
        viewpoint.n_unoccluded   = viewpoint.n_unoccluded + 1;
        viewpoint.idx_unoccluded = [viewpoint.idx_unoccluded i];        
    end
    
    if( i <= n_parts_child )
        viewpoint.parts{i}.is_root = 0;
        
        % part locations
        p = R*[parts_unoccluded(i).x parts_unoccluded(i).y ones(numel(parts_unoccluded(i).x), 1)]';
        p = p(1:2,:)';
        c = R*[parts_unoccluded(i).center, 1]';
        c = c(1:2)';
        
        % construct the coefficient matrix
        X = p - repmat(c, size(p,1), 1);
        xprim = param.cad.parts2d_front(i).vertices;
        H = homography_from_shape(X,xprim);

        viewpoint.parts{i}.shape = X;
        viewpoint.parts{i}.center = c - R(1:2,3)';
        viewpoint.parts{i}.homography = H;
    else
        viewpoint.parts{i}.is_root = 1;
        viewpoint.parts{i}.center = [0 0];
    end
end    

end

function [ H ] = homography_from_shape( s1, s2 )

A = zeros(8,9);
X = s1;
xprim = s2;
for j = 1:4
    x = [X(j,:), 1];
    A(2*j-1,:) = [zeros(1,3), -x, xprim(j,2)*x];
    A(2*j, :)  = [x, zeros(1,3), -xprim(j,1)*x];
end
[~, ~, V] = svd(A);
% homography
h = V(:,end);
H = reshape(h, 3, 3)';
H = H ./ H(3,3);

end

