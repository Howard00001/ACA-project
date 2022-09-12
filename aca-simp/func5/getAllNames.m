function names = getAllNames(paths, cattype)
    tmp = split(paths,'/');
    files = tmp(:,:,end);
    tmp = split(files,'-');
    if cattype
        names = strcat(tmp(:,:,1), '-',tmp(:,:,2));
    else
        names = tmp(:,:,1);
    end
    names = unique(names);
end