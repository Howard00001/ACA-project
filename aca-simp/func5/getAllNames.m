function names = getAllNames(paths)
    tmp = split(paths,'/');
    files = tmp(:,:,end);
    tmp = split(files,'-');
    names = strcat(tmp(:,:,1), '-',tmp(:,:,2));
    names = unique(names);
end