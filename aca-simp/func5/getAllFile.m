function paths = getAllFile(path)
    paths = {};
    dirs = dir(path);
    folder = {dirs.folder};
    folder = folder{1};
    file = {dirs.name};
    for i=3:size(dirs,1)
        paths{i-2} = strcat(folder,'/',file{i});
    end
end