function net=shuffle_hop(net)

W = net.LW{1,1};

W_new = zeros(size(W));

idx = find(diag(ones(size(W,1),1)));
vals = W(idx);
perm = randperm(length(vals));
vals = vals(perm);
W_new(idx) = vals;

idx = find(~triu(ones(size(W))));
vals = W(idx);
perm = randperm(length(vals));
vals = vals(perm);
W_new(idx) = vals;

for i=1:size(W,1)-1
    for j=i+1:size(W,1)
        W_new(i,j)=W_new(j,i);
    end
end

b = net.b{1,1};
perm = randperm(length(b));
b_new = b(perm);

net.LW{1,1} = W_new;
net.b{1,1} = b_new;

end