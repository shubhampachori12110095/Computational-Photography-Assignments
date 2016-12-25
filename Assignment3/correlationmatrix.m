function d = correlationmatrix(Features1,Features2)
n = size(Features1,2);
d = zeros(size(Features1,1),size(Features2,1));
for i = 1:size(Features1,1)
    for j = 1:size(Features2,1)
        d1 = (Features1(i,:) - mean(Features1(i,:))) / std(double(Features1(i,:)));
        d2 = (Features2(j,:) - mean(Features2(j,:))) / std(double(Features2(j,:)));
        ncc_value = (sum(d1.*d2)) /(n- 1);
        if (ncc_value > 0)
          d(i,j) = ncc_value;
        end
    end
end 

k = 1;
for i = 1:size(d,2)
  a = d(:,i);    
  ff = find(a == max(a));
  for j = 1:length(ff)
    gg(k,:) = [ff(j),i];
    k = k+1;
  end
end

[rows,cols] = size(d);
H = zeros(rows,cols);
for i = 1:size(gg,1)
    H(gg(i,1),gg(i,2)) = d(gg(i,1),gg(i,2));
end 
d = H;

k = 1;
for i = 1:size(d,1)
  a = d(i,:);    
  ff = find(a == max(a));
  for j = 1:length(ff)
    gg(k,:) = [i,ff(j)];
    k = k+1;
  end
end

[rows,cols] = size(d);
H = zeros(rows,cols);
for i = 1:size(gg,1)
    H(gg(i,1),gg(i,2)) = d(gg(i,1),gg(i,2));
end 
d = H;


end
