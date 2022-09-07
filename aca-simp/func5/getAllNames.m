function names = getAllNames(paths)
    tmp = split(paths,'/');
    files = tmp(:,:,-1);
    tmp = split(files,'-');
    names = tmp(:,:,2);
    names = unique(names);
end